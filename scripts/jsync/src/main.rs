use anyhow::{anyhow, Context, Result};
use clap::{Parser, Subcommand};
use std::path::Path;
use std::process::Command;

#[derive(Parser)]
#[command(name = "jsync")]
#[command(about = "A simple file synchronization tool using rsync")]
#[command(version)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Upload a directory to a remote host
    Up {
        /// Remote host (user@host.com)
        remote: String,
        /// Path to sync
        path: String,
        /// Additional rsync arguments
        #[arg(trailing_var_arg = true)]
        args: Vec<String>,
    },
    /// Download a directory from a remote host
    Down {
        /// Remote host (user@host.com)
        remote: String,
        /// Path to sync
        path: String,
        /// Additional rsync arguments
        #[arg(trailing_var_arg = true)]
        args: Vec<String>,
    },
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Commands::Up { remote, path, args } => {
            run_rsync(&remote, &path, true, &args)
        }
        Commands::Down { remote, path, args } => {
            run_rsync(&remote, &path, false, &args)
        }
    }
}

fn run_rsync(remote: &str, path: &str, upload: bool, extra_args: &[String]) -> Result<()> {
    let canonical = Path::new(path)
        .canonicalize()
        .with_context(|| format!("Failed to resolve path: {}", path))?;
    let mut path = canonical
        .to_str()
        .ok_or_else(|| anyhow!("Path is not valid UTF-8: {}", canonical.display()))?
        .to_string();
    if canonical.is_dir() && !path.ends_with('/') {
        path.push('/');
    }

    println!(
      "{} '{}' to '{}' with args: {:?}",
      if upload {"Uploading"} else {"Downloading"}, path, remote, extra_args
    );

    let mut cmd = Command::new("rsync");

    // Add default arguments
    cmd.arg("-ahv").arg("--delete");

    // Add extra arguments
    for arg in extra_args {
        cmd.arg(arg);
    }

    if upload {
        cmd.arg(&path).arg(format!("{}:{}", remote, path));
    } else {
        cmd.arg(format!("{}:{}", remote, path)).arg(&path);
    }

    let status = cmd.status().context("Failed to execute rsync")?;

    if !status.success() {
        anyhow::bail!(
            "rsync failed with exit code: {}",
            status.code().unwrap_or(-1)
        );
    }

    Ok(())
}
