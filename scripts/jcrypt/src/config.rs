use serde::Deserialize;
use std::collections::HashMap;
use std::fs;
use std::path::PathBuf;

#[derive(Debug, Deserialize)]
pub struct Config {
    #[serde(default = "default_mount_base")]
    pub mount_base: String,
    #[serde(default = "default_file_manager")]
    pub file_manager: String,
    #[serde(default)]
    pub symlink: bool,
    #[serde(default)]
    pub vaults: HashMap<String, String>,
}

fn default_mount_base() -> String {
    "/mnt/crypt".into()
}

fn default_file_manager() -> String {
    "xdg-open".into()
}

impl Config {
    pub fn load(path: &str) -> Self {
        let content = fs::read_to_string(path).unwrap_or_else(|e| {
            eprintln!("error: cannot read config {path}: {e}");
            std::process::exit(1);
        });
        toml::from_str(&content).unwrap_or_else(|e| {
            eprintln!("error: cannot parse config {path}: {e}");
            std::process::exit(1);
        })
    }
}

pub fn config_path() -> PathBuf {
    if let Ok(p) = std::env::var("JCRYPT_CONFIG") {
        if !p.is_empty() {
            return PathBuf::from(p);
        }
    }
    let dir = dirs::config_dir().unwrap_or_else(|| {
        eprintln!("error: cannot determine config directory");
        std::process::exit(1);
    });
    dir.join("jcrypt").join("config.toml")
}
