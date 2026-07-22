use crate::filter;
use futures_util::{SinkExt, StreamExt};
use serde_json::{json, Value};
use std::collections::HashMap;
use std::env;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Arc, RwLock};
use tokio::sync::{broadcast, mpsc};
use tokio_tungstenite::{connect_async, tungstenite::Message, MaybeTlsStream, WebSocketStream};
use tokio::net::TcpStream;

type WsWriter = futures_util::stream::SplitSink<WebSocketStream<MaybeTlsStream<TcpStream>>, Message>;

async fn process_ws_message(
    text: &str,
    write: &mut WsWriter,
    tx: &broadcast::Sender<Value>,
    cache: &Arc<RwLock<HashMap<String, Value>>>,
    token: &str,
    msg_id: &AtomicU64,
) -> Result<bool, Box<dyn std::error::Error>> {
    let parsed: Value = match serde_json::from_str(text) {
        Ok(v) => v,
        Err(_) => return Ok(true),
    };

    let Some(msg_type) = parsed.get("type").and_then(|v| v.as_str()) else {
        return Ok(true);
    };

    match msg_type {
        "auth_required" => {
            let auth_msg = json!({
                "type": "auth",
                "access_token": token,
            });
            if write.send(Message::Text(auth_msg.to_string())).await.is_err() {
                return Ok(false);
            }
        }
        "auth_ok" => {
            println!("Authenticated successfully!");

            let sub_msg = json!({
                "id": msg_id.fetch_add(1, Ordering::SeqCst),
                "type": "subscribe_events",
                "event_type": "state_changed",
            });
            if write.send(Message::Text(sub_msg.to_string())).await.is_err() {
                return Ok(false);
            }
        }
        "auth_invalid" => {
            eprintln!("Authentication failed: {}", parsed);
            return Err("authentication failed".into());
        }
        "result" => {
            let success = parsed.get("success").and_then(|v| v.as_bool()).unwrap_or(false);
            if success {
                println!("Subscription successful: {}", parsed);
            } else {
                eprintln!("Command failed: {}", parsed);
            }
        }
        "event" => {
            if let Some(event) = parsed.get("event") {
                if let Some(transformed) = filter::transform_event(event) {
                    let entity_id = transformed
                        .get("entity_id")
                        .and_then(|v| v.as_str())
                        .map(|s| s.to_owned())
                        .unwrap_or_default();
                    cache.write().unwrap().insert(entity_id, transformed.clone());
                    println!(
                        "Event: {}",
                        serde_json::to_string_pretty(&transformed).unwrap()
                    );
                    let _ = tx.send(transformed);
                }
            }
        }
        _ => {
            println!("Received: {}", text);
        }
    }

    Ok(true)
}

async fn handle_connection(
    ws_stream: WebSocketStream<MaybeTlsStream<TcpStream>>,
    tx: broadcast::Sender<Value>,
    cache: Arc<RwLock<HashMap<String, Value>>>,
    rx: &mut mpsc::UnboundedReceiver<String>,
    token: &str,
    msg_id: Arc<AtomicU64>,
) -> Result<(), Box<dyn std::error::Error>> {
    let (mut write, mut read) = ws_stream.split();

    loop {
        tokio::select! {
            msg = read.next() => {
                match msg {
                    Some(Ok(msg)) => {
                        if !msg.is_text() {
                            continue;
                        }
                        let text = match msg.to_text() {
                            Ok(t) => t.to_owned(),
                            Err(_) => continue,
                        };
                        match process_ws_message(&text, &mut write, &tx, &cache, token, &msg_id).await {
                            Ok(true) => {}
                            Ok(false) => break,
                            Err(e) => return Err(e),
                        }
                    }
                    Some(Err(e)) => {
                        eprintln!("WebSocket error: {e}");
                        break;
                    }
                    None => {
                        println!("WebSocket connection closed");
                        break;
                    }
                }
            }
            cmd = rx.recv() => {
                match cmd {
                    Some(text) => {
                        let modified = match serde_json::from_str::<Value>(&text) {
                            Ok(mut parsed) => {
                                parsed["id"] = json!(msg_id.fetch_add(1, Ordering::SeqCst));
                                parsed.to_string()
                            }
                            Err(_) => text,
                        };
                        if write.send(Message::Text(modified)).await.is_err() {
                            break;
                        }
                    }
                    None => {
                        return Ok(());
                    }
                }
            }
        }
    }

    Ok(())
}

pub async fn run(
    tx: broadcast::Sender<Value>,
    mut rx: mpsc::UnboundedReceiver<String>,
    cache: Arc<RwLock<HashMap<String, Value>>>,
    msg_id: Arc<AtomicU64>,
) -> Result<(), Box<dyn std::error::Error>> {
    let hass_url = env::var("HASS_URL").expect("HASS_URL must be set");
    let token = env::var("HASS_TOKEN").expect("HASS_TOKEN must be set");

    let ws_url = hass_url
        .replace("http://", "ws://")
        .replace("https://", "wss://")
        + "/api/websocket";

    let max_retries = 8;
    let mut retries = 0;
    let mut delay = 2u64;

    loop {
        println!("Connecting to Home Assistant at {ws_url}...");

        match connect_async(&ws_url).await {
            Ok((ws_stream, _)) => {
                retries = 0;
                delay = 2;

                match handle_connection(ws_stream, tx.clone(), cache.clone(), &mut rx, &token, msg_id.clone()).await {
                    Err(e) => return Err(e),
                    Ok(()) => {}
                }

                println!("Disconnected from Home Assistant");
            }
            Err(e) => {
                eprintln!("Connection failed: {e}");
            }
        }

        retries += 1;
        if retries > max_retries {
            eprintln!("Max retries ({max_retries}) reached. Giving up.");
            return Err("connection failed after max retries".into());
        }

        println!(
            "Reconnecting in {delay}s... (attempt {retries}/{max_retries})"
        );
        tokio::time::sleep(tokio::time::Duration::from_secs(delay)).await;
        delay = (delay * 2).min(30);
    }
}
