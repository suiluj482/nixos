use clap::{Parser, Subcommand};
use std::process::Command;
use std::fs;
use anyhow::{Result, Context};
use std::env;

mod utils;
use utils::{run, Inhibitor, get_value};

mod config;
use config::{SCRIPTS_RUST};

#[derive(Parser)]
#[command(name = "nixos")]
#[command(about = "Manage NixOS tasks", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    Update,
    Rebuild {
        #[arg(last = true)]
        extra_args: Vec<String>,
    },
    Garbage,
    Commit {
        message: String,
    },
    Open,
    Cd,
    Iso {
        #[arg(last = true)]
        extra_args: Vec<String>,
    },
    PushAndRebuild {
        remote: String,
    },
    Shutdown,
    Check,
    Clear,
}



fn main() -> Result<()> {
    let cli = Cli::parse();

    // Assume paths.nixos and system-name env vars
    let nixos_path = get_value("PATHS_NIXOS");
    let system_name = get_value("SYSTEM_NAME");

    // Change working directory to nixos_path
    env::set_current_dir(&nixos_path)
        .with_context(|| format!("Failed to change directory to {}", nixos_path))?;

    match cli.command {
        Commands::Update => rebuild_update(&[], &system_name)?,
        Commands::Rebuild { extra_args } => rebuild(&extra_args, &system_name)?,
        Commands::Garbage => garbage()?,
        Commands::Commit { message } => commit(&message)?,
        Commands::Open => open_editor()?,
        Commands::Cd => change_shell()?,
        Commands::Iso { extra_args } => build_iso(&extra_args)?,
        Commands::PushAndRebuild { remote } => push_and_rebuild(&remote, &nixos_path)?,
        Commands::Shutdown => shutdown_update(&system_name)?,
        Commands::Check => check()?,
        Commands::Clear => clear()?,
    }

    Ok(())
}

// ======= Implementations =======

fn open_editor() -> Result<()> {
  run(&mut Command::new("codium").arg("."))?;
  Ok(())
}

fn change_shell() -> Result<()> {
  let shell = std::env::var("SHELL").unwrap_or_else(|_| "/bin/bash".to_string());
  run(&mut Command::new(shell))?;
  Ok(())
}

fn has_staged_changes(paths: &[&str]) -> Result<bool> {
    let status = Command::new("git")
        .args(["diff", "--cached", "--quiet"])
        .args(paths)
        .status()
        .context("Failed to check git status")?;
    Ok(!status.success())
}

fn commit(message: &str) -> Result<()> {
  run(&mut Command::new("git").args(["add", "."]))?;
  run(&mut Command::new("git").args(["commit", "-m", message]))?;
  Ok(())
}

fn update_scripts() -> Result<Vec<String>> {
  let mut lock_files = Vec::new();
  for script in SCRIPTS_RUST {
    println!("Updating rust script {}", script);
    let dir = format!("scripts/{}", script);
    run(Command::new("nix").args(["flake", "update"]).current_dir(&dir))?;
    run(Command::new("nix")
      .args(["develop", "-c", "cargo", "update"])
      .current_dir(&dir))?;
    let flake_lock = format!("{}/flake.lock", dir);
    let cargo_lock = format!("{}/Cargo.lock", dir);
    run(&mut Command::new("git").args(["add", &flake_lock, &cargo_lock]))?;
    lock_files.push(flake_lock);
    lock_files.push(cargo_lock);
  }
  Ok(lock_files)
}

fn update() -> Result<()> {
  let _i = Inhibitor::new("nixos-cli: nix update");
  let mut lock_files = update_scripts()?;
  run(&mut Command::new("nix").args(["flake", "update"]))?;
  run(&mut Command::new("git").args(["add", "flake.lock"]))?;
  lock_files.push("flake.lock".to_string());
  let refs: Vec<&str> = lock_files.iter().map(String::as_str).collect();
  if has_staged_changes(&refs)? {
    run(&mut Command::new("git")
      .arg("commit").arg("--only")
      .args(&lock_files)
      .args(["-m", "update"])
    )?;
  }
  Ok(())
}

fn rebuild(extra_args: &[String], system_name: &str) -> Result<()> {
  run(&mut Command::new("git").args(["add", "."]))?;
  {
    let _i = Inhibitor::new("nixos-cli: nix build");
    run(
      &mut Command::new("sudo").arg("nixos-rebuild").arg("switch")
      .arg("--flake").arg(format!(".#{}", system_name))
      .args(extra_args)
    )?;
  }
  Ok(())
  // todo: systemctl is-active --quiet home-manager-suiluj.service || echo "⚠ home-manager failed!"
  // systemctl status home-manager-suiluj.service
}

fn rebuild_update(extra_args: &[String], system_name: &str) -> Result<()> {
  run(&mut Command::new("sudo").arg("-v"))?;
  update()?;
  rebuild(extra_args, system_name)?;
  Ok(())
}

fn status_path() -> Result<String> {
    let home = env::var("HOME").context("HOME not set")?;
    Ok(format!("{}/.local/state/nixos-cli/status", home))
}
fn write_status_path(content: &str) -> Result<()> {
  let path = status_path()?;
  fs::create_dir_all(std::path::Path::new(&path).parent().unwrap())?;
  fs::write(&path, &content)?;
  Ok(())
}

fn shutdown_update(system_name: &str) -> Result<()> {
  let status = if let Err(e) = rebuild_update(&[], system_name) {
    eprintln!("Warning: rebuild failed, proceeding with shutdown: {e:#}");
    format!("{e:#}")
  } else {
    String::new()
  };
  write_status_path(&status)?;
  run(&mut Command::new("shutdown").arg("now"))?;
  Ok(())
}

fn check() -> Result<()> {
    let status_path = status_path()?;

    if let Ok(content) = fs::read_to_string(&status_path) {
        if !content.trim().is_empty() {
            Command::new("kitty")
                .args(["sh", "-c", &format!("cat {} && exec $SHELL", status_path)])
                .spawn()
                .context("Failed to launch kitty")?;
        }
    }
    Ok(())
}

fn clear() -> Result<()> {
  write_status_path("")?;
  Ok(())
}

fn garbage() -> Result<()> {
  run(&mut Command::new("home-manager").args(["expire-generations", "-1", "days"]))?;
  run(&mut Command::new("sudo").args(["nix-collect-garbage", "--delete-old"]))?;
  Ok(())
}

fn build_iso(extra_args: &[String]) -> Result<()> {
  let iso_name = get_value("ISO_NAME");
  run(
    &mut Command::new("nix")
    .arg("build")
    .arg(format!(".#nixosConfigurations.{}.config.system.build.isoImage", iso_name))
    .args(extra_args)
  )?;
  Ok(())
}

fn push_and_rebuild(remote: &str, nixos_path: &str) -> Result<()> {
  println!("Syncing and rebuilding to {}", remote);
  run(&mut Command::new("jsync").args(["up", remote, nixos_path]))?;
  run(&mut Command::new("ssh").args(["-t", remote, "nixos rebuild"]))?;
  Ok(())
}

// Todo: command to kill sleep inhibitors 