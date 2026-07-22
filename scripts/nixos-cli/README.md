# NixOS CLI Tool

A Rust-based CLI tool for NixOS system management, built with clap.

## Development

### Using the Nix Development Shell

```bash
# Enter the development environment
nix develop

# Build the project
cargo build

# Run with cargo
cargo run -- --help

# Run tests
cargo test

# Format code
cargo fmt

# Run linter
cargo clippy
```

### Building the Package

```bash
# Build using the Nix flake
nix build

# Run the built binary
./result/bin/nixos-cli --help

# Build without the env var wrapper
nix build .#bare
```

## Available Commands

- `update` - Update flake and rebuild system
- `shutdown` - Update, rebuild, then shut down
- `garbage` - Clean up old Nix garbage
- `commit <message>` - Commit changes with message
- `open` - Open current directory in editor
- `cd` - Start interactive bash session
- `rebuild [args...]` - Rebuild system from configuration
- `iso [args...]` - Build ISO image
- `pushAndRebuild <remote>` - Push to remote and rebuild

## Dependencies

The tool requires the following system dependencies:
- systemd (for nixos-rebuild, shutdown commands)
- git (for version control operations)
- codium (for the open command)
- jsync (for pushAndRebuild functionality)