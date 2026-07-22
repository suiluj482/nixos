use std::io::{BufRead, BufReader};
use std::process::{Command, Stdio};
use zbus::zvariant::OwnedFd;
use anyhow::{Result, Context, bail};
use std::env;
use dialoguer::Input;
use zbus::blocking::Connection;


pub fn run(cmd: &mut Command) -> Result<()> {
    let program = format!("{:?}", cmd.get_program());
    let mut child = cmd
        .stdout(Stdio::piped())
        .spawn()
        .with_context(|| format!("Failed to execute {program}"))?;

    let stdout = child.stdout.take().unwrap();
    let reader = BufReader::new(stdout);
    let mut captured = String::new();

    for line in reader.lines() {
        let line = line.context("Failed to read output")?;
        println!("{line}");
        captured.push_str(&line);
        captured.push('\n');
    }

    let status = child
        .wait()
        .with_context(|| format!("Failed to wait for {program} to finish"))?;

    if !status.success() {
        let exit_code = status.code().unwrap_or(1);
        let mut msg = format!("{program} exited with code {exit_code}");
        if !captured.is_empty() {
            msg.push_str(&format!("\nstdout:\n{}", captured.trim_end()));
        }
        bail!("{msg}");
    }

    Ok(())
}

pub struct Inhibitor {
  fd: Option<OwnedFd>,
}

impl Inhibitor {
  pub fn new(reason: &str) -> Self {
    let fd = inhibit("shutdown:sleep", "nixos-cli", reason, "block")
      .expect("failed to create inhibitor via logind");
    Self { fd: Some(fd) }
  }

  pub fn release(&mut self) {
    if let Some(fd) = self.fd.take() {
      drop(fd);
    }
  }
}

impl Drop for Inhibitor {
  fn drop(&mut self) {
      self.release();
  }
}

fn inhibit(what: &str, who: &str, why: &str, mode: &str) -> zbus::Result<OwnedFd> {
  let connection = Connection::system()?;
  let body = connection
    .call_method(
      Some("org.freedesktop.login1"),
      "/org/freedesktop/login1",
      Some("org.freedesktop.login1.Manager"),
      "Inhibit",
      &(what, who, why, mode),
    )?
    .body();
  body.deserialize()
}

pub fn get_value(name: &str) -> String {
  match env::var(&name) {
    Ok(value) => value,
    Err(_) => {
      Input::new()
        .with_prompt(format!("Enter value for {} (default: .)", name))
        .default(".".to_string())
        .interact()
        .unwrap_or_else(|_| ".".to_string())
    }
  }
}
