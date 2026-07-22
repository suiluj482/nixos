use clap::{Parser, Subcommand};
use std::collections::HashMap;
use std::fs;
use std::path::PathBuf;
use std::process::Command;

use crate::config::{config_path, Config};
use crate::util::symlink_path;

#[derive(Parser)]
#[command(name = "jcrypt", about = "Manage gocryptfs vaults")]
struct Cli {
    /// Config file (default: $JCRYPT_CONFIG or ~/.config/jcrypt/config.toml)
    #[arg(long, global = true)]
    config: Option<String>,

    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Mount a vault
    Mount {
        /// Vault name
        name: String,
        /// Open file manager after mounting
        #[arg(short = 'o', long)]
        open: bool,
        /// Override configured file manager
        #[arg(long)]
        file_manager: Option<String>,
    },
    /// Unmount a vault
    #[command(alias = "umount")]
    #[command(alias = "u")]
    Unmount {
        /// Vault name
        name: String,
    },
    /// Inspect configured vaults
    Vault {
        #[command(subcommand)]
        command: VaultCommands,
    },
}

#[derive(Subcommand)]
enum VaultCommands {
    /// List configured vaults
    List,
}

pub fn run() {
    let cli = Cli::parse();
    let cfg_path = cli.config.unwrap_or_else(|| config_path().to_string_lossy().to_string());

    match cli.command {
        Commands::Mount { name, open, file_manager } => {
            let cfg = Config::load(&cfg_path);
            let (enc_path, mnt) = resolve_vault(&cfg, &name);
            println!("encrypted: {enc_path}");
            println!("mount:     {mnt}");
            do_mount(&enc_path, &mnt);
            if cfg.symlink {
                do_symlink(&enc_path, &mnt);
            }
            if open {
                let fm = file_manager.unwrap_or(cfg.file_manager);
                do_open_file_manager(&fm, &mnt);
            }
        }
        Commands::Unmount { name } => {
            let cfg = Config::load(&cfg_path);
            let (enc_path, mnt) = resolve_vault(&cfg, &name);
            println!("unmounting: {mnt}");
            do_unmount(&mnt);
            if cfg.symlink {
                remove_symlink(&enc_path);
            }
        }
        Commands::Vault { command } => match command {
            VaultCommands::List => {
                let cfg = Config::load(&cfg_path);
                if cfg.vaults.is_empty() {
                    println!("No vaults configured.");
                    return;
                }
                let mut names: Vec<&String> = cfg.vaults.keys().collect();
                names.sort();
                println!("{:<20} {}", "NAME", "PATH");
                for n in names {
                    println!("{n:<20} {}", cfg.vaults[n]);
                }
            }
        },
    }
}

fn resolve_vault(cfg: &Config, name: &str) -> (String, String) {
    let enc_path = cfg.vaults.get(name).unwrap_or_else(|| {
        eprint!("error: unknown vault {name:?}");
        eprint!("configured vaults:");
        let mut names: Vec<&String> = cfg.vaults.keys().collect();
        names.sort();
        for k in names {
            eprint!(" {k}");
        }
        eprintln!();
        std::process::exit(1);
    });
    let mnt = PathBuf::from(&cfg.mount_base).join(name);
    (enc_path.clone(), mnt.to_string_lossy().to_string())
}

fn do_mount(enc_path: &str, mnt: &str) {
    fs::create_dir_all(mnt).unwrap_or_else(|e| {
        eprintln!("error: create mount point: {e}");
        std::process::exit(1);
    });
    let status = Command::new("gocryptfs")
        .arg(enc_path)
        .arg(mnt)
        .stdin(std::process::Stdio::inherit())
        .stdout(std::process::Stdio::inherit())
        .stderr(std::process::Stdio::inherit())
        .status()
        .unwrap_or_else(|e| {
            eprintln!("error: gocryptfs: {e}");
            std::process::exit(1);
        });
    if !status.success() {
        eprintln!("error: gocryptfs exited with {status}");
        std::process::exit(1);
    }
}

fn do_unmount(mnt: &str) {
    let status = Command::new("fusermount")
        .arg("-u")
        .arg(mnt)
        .stdout(std::process::Stdio::inherit())
        .stderr(std::process::Stdio::inherit())
        .status()
        .unwrap_or_else(|e| {
            eprintln!("error: fusermount: {e}");
            std::process::exit(1);
        });
    if !status.success() {
        eprintln!("error: fusermount exited with {status}");
        std::process::exit(1);
    }
}

fn do_symlink(enc_path: &str, mnt: &str) {
    let Some(target) = symlink_path(enc_path) else {
        return;
    };
    let _ = fs::remove_file(&target);
    std::os::unix::fs::symlink(mnt, &target).unwrap_or_else(|e| {
        eprintln!("error: create symlink: {e}");
        std::process::exit(1);
    });
    println!("symlink:   {target} -> {mnt}");
}

fn remove_symlink(enc_path: &str) {
    let Some(target) = symlink_path(enc_path) else {
        return;
    };
    if let Err(e) = fs::remove_file(&target) {
        if e.kind() != std::io::ErrorKind::NotFound {
            eprintln!("warning: could not remove symlink {target}: {e}");
        }
    }
}

fn do_open_file_manager(file_manager: &str, mnt: &str) {
    let _ = Command::new(file_manager)
        .arg(mnt)
        .stdout(std::process::Stdio::inherit())
        .stderr(std::process::Stdio::inherit())
        .spawn()
        .map_err(|e| {
            eprintln!("warning: could not open file manager: {e}");
        });
}
