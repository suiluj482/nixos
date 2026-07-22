# jsync

A simple file synchronization tool using rsync, written in Rust.

## Features

- Upload directories to remote hosts
- Download directories from remote hosts
- Relative and absolute path support (paths are canonicalized before sync)
- Pass additional rsync arguments
- Built-in rsync defaults (`-ah --delete`)
- Clean CLI interface with help messages

## Installation

### NixOS / Home Manager

Add to your configuration:

```nix
imports = [
  ./scripts/jsync/module.nix
];

programs.jsync.enable = true;
```

### From source

```bash
cargo build --release
./target/release/jsync --help
```

## Usage

### Upload a directory

```bash
jsync up user@host.com /path/to/directory
jsync up user@host.com ./relative/path   # resolves to absolute path
```

### Download a directory

```bash
jsync down user@host.com /path/to/directory
jsync down user@host.com ./relative/path   # resolves to absolute path
```

Relative paths are resolved to absolute before sync. The same absolute path is used on both local and remote sides (e.g., `./mydir` becomes `/home/user/projects/mydir` on both).

### With additional rsync arguments

```bash
jsync up user@host.com /path/to/directory --progress -v
jsync down user@host.com /path/to/directory --exclude="*.log"
```

## Development

### Prerequisites

- Rust toolchain
- Nix (optional)

### Building

```bash
# Using cargo
cargo build

# Using nix-build
nix-build -A package
```

### Linting

```bash
cargo clippy
cargo fmt --check
```

## License

MIT