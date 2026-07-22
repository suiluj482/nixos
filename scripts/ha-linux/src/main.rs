mod filter;
mod ha;
mod ipc;

use serde_json::Value;
use std::collections::HashMap;
use std::sync::atomic::AtomicU64;
use std::sync::{Arc, RwLock};
use tokio::sync::{broadcast, mpsc};

#[tokio::main]
async fn main() {
    dotenvy::dotenv().ok();

    let (tx, _) = broadcast::channel::<Value>(256);
    let (ha_tx, ha_rx) = mpsc::unbounded_channel::<String>();
    let cache: Arc<RwLock<HashMap<String, Value>>> = Arc::new(RwLock::new(HashMap::new()));
    let id_counter: Arc<AtomicU64> = Arc::new(AtomicU64::new(1));

    tokio::spawn(ipc::serve(tx.clone(), ha_tx, cache.clone()));

    if let Err(e) = ha::run(tx, ha_rx, cache, id_counter).await {
        eprintln!("Error: {e}");
        ipc::clean_up();
        std::process::exit(1);
    }
}
