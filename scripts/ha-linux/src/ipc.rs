use crate::filter;
use serde_json::Value;
use std::collections::HashMap;
use std::env;
use std::marker::Unpin;
use std::sync::{Arc, RwLock};
use tokio::io::{AsyncBufReadExt, AsyncWrite, AsyncWriteExt, BufReader};
use tokio::net::UnixListener;
use tokio::sync::{broadcast, mpsc};

pub fn socket_path() -> String {
    env::var("HA_IPC_SOCKET").unwrap_or_else(|_| {
        let dir = env::var("XDG_RUNTIME_DIR").expect("XDG_RUNTIME_DIR must be set");
        format!("{dir}/ha-linux.sock")
    })
}

pub fn clean_up() {
    let _ = std::fs::remove_file(socket_path());
}

/// Parse and apply a subscribe/unsubscribe command from a client.
/// Returns `true` if the line was handled as a subscription command,
/// `false` if it should be forwarded to HA.
async fn handle_commands(
    line: &str,
    subscription: &mut Option<Vec<String>>,
    write_half: &mut (impl AsyncWrite + Unpin),
    cache: &Arc<RwLock<HashMap<String, Value>>>,
) -> bool {
    let val = match serde_json::from_str::<Value>(line) {
        Ok(v) => v,
        Err(_) => return false,
    };

    if val.get("subscribe").is_some() {
        let patterns: Vec<String> = val
            .get("subscribe")
            .and_then(|s| s.get("entities"))
            .and_then(|e| e.as_array())
            .map(|arr| arr.iter().filter_map(|v| v.as_str().map(String::from)).collect())
            .unwrap_or_default();
        let current = subscription.get_or_insert_with(Vec::new);
        for p in patterns {
            if !current.contains(&p) {
                current.push(p);
            }
        }
        // Send cached state for all matching entities
        let entries: Vec<Value> = {
            let guard = cache.read().unwrap();
            guard
                .iter()
                .filter(|(eid, _)| current.iter().any(|p| filter::entity_matches(p, eid)))
                .map(|(_, ev)| ev.clone())
                .collect()
        };
        for ev in &entries {
            if let Ok(json) = serde_json::to_string(ev) {
                let _ = write_half.write_all(json.as_bytes()).await;
                let _ = write_half.write_all(b"\n").await;
            }
        }
        println!("IPC client subscribed to: {:?}", subscription);
        return true;
    }

    if val.get("unsubscribe").is_some() {
        let remove: Vec<String> = val
            .get("unsubscribe")
            .and_then(|u| u.get("entities"))
            .and_then(|e| e.as_array())
            .map(|arr| arr.iter().filter_map(|v| v.as_str().map(String::from)).collect())
            .unwrap_or_default();
        if let Some(ref mut current) = subscription {
            current.retain(|p| !remove.contains(p));
            if current.is_empty() {
                *subscription = None;
            }
        }
        println!("IPC client unsubscribed from: {:?}", remove);
        return true;
    }

    false
}

pub async fn serve(
    tx: broadcast::Sender<Value>,
    ha_tx: mpsc::UnboundedSender<String>,
    cache: Arc<RwLock<HashMap<String, Value>>>,
) {
    let path = socket_path();
    let _ = std::fs::remove_file(&path);

    let listener = match UnixListener::bind(&path) {
        Ok(l) => l,
        Err(e) => {
            eprintln!("Failed to bind IPC socket at {path}: {e}");
            return;
        }
    };
    println!("IPC server listening on {path}");

    loop {
        match listener.accept().await {
            Ok((stream, addr)) => {
                println!("IPC client connected: {:?}", addr);
                let rx = tx.subscribe();
                let ha_tx = ha_tx.clone();
                let cache = cache.clone();
                tokio::spawn(handle_client(stream, rx, ha_tx, cache));
            }
            Err(e) => eprintln!("IPC accept error: {e}"),
        }
    }
}

async fn handle_client(
    stream: tokio::net::UnixStream,
    mut rx: broadcast::Receiver<Value>,
    ha_tx: mpsc::UnboundedSender<String>,
    cache: Arc<RwLock<HashMap<String, Value>>>,
) {
    let (read_half, mut write_half) = stream.into_split();
    let mut reader = BufReader::new(read_half);
    let mut line = String::new();
    let mut subscription: Option<Vec<String>> = None;

    loop {
        tokio::select! {
            result = rx.recv() => {
                match result {
                    Ok(event) => {
                        if let Some(ref patterns) = subscription {
                            let entity_id = event.get("entity_id")
                                .and_then(|v| v.as_str())
                                .unwrap_or("");
                            if !patterns.iter().any(|p| filter::entity_matches(p, entity_id)) {
                                continue;
                            }
                        }
                        let json = serde_json::to_string(&event).unwrap();
                        if write_half.write_all(json.as_bytes()).await.is_err()
                            || write_half.write_all(b"\n").await.is_err()
                        {
                            break;
                        }
                    }
                    Err(broadcast::error::RecvError::Lagged(n)) => {
                        eprintln!("IPC client lagged by {n} events");
                    }
                    Err(broadcast::error::RecvError::Closed) => break,
                }
            }
            result = reader.read_line(&mut line) => {
                match result {
                    Ok(0) => break,
                    Ok(_) => {
                        let trimmed = line.trim().to_string();
                        line.clear();
                        if trimmed.is_empty() {
                            continue;
                        }

                        if handle_commands(&trimmed, &mut subscription, &mut write_half, &cache).await
                        {
                            continue;
                        }

                        let _ = ha_tx.send(trimmed);
                    }
                    Err(e) => {
                        eprintln!("IPC read error: {e}");
                        break;
                    }
                }
            }
        }
    }
}
