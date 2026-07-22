# jcrypt

A CLI wrapper around [gocryptfs](https://github.com/rfjakob/gocryptfs) with named vaults.

## Usage

```
jcrypt mount <vault>                     # mount, prompts for password
jcrypt mount <vault> -o                  # mount and open file manager
jcrypt mount <vault> -o --file-manager dolphin  # override file manager
jcrypt unmount <vault>                   # unmount  (aliases: umount, u)

jcrypt vault list                        # list vaults from config

jcrypt --config /path/to/config.toml mount <vault>  # override config file
```

## Config file

Managed by home-manager. Default location: `~/.config/jcrypt/config.toml`.
Override via `$JCRYPT_CONFIG` env var or `--config` flag.

```toml
mount_base   = "/mnt/crypt"
file_manager = "xdg-open"   # used with --open / -o
symlink      = true         # create a "decrypted" sibling symlink (see below)

[vaults]
akten  = "/home/julius/documents/akten/other/encrypted"
notes  = "/home/julius/documents/notes/other/encrypted"
system = "/home/julius/documents/system/other/encrypted"
media  = "/home/julius/js/media/other/encrypted"
```

### Symlink behaviour

When `symlink = true`, mounting a vault whose encrypted path ends with
`encrypted` automatically creates a sibling symlink ending with `decrypted`
pointing at the live mount:

```
~/documents/notes/other/encrypted   ← gocryptfs source
~/documents/notes/other/decrypted   → /mnt/crypt/notes  (symlink, created on mount)
```

The symlink is removed on `unmount`.

## Home Manager module

jcrypt ships a home-manager module (`jcrypt.nix`) that builds the Rust package,
generates the config file, and installs both `jcrypt` and `gocryptfs`.

### Quick setup

Import the module in your home-manager config:

```nix
# home.nix or wherever your HM config lives
{ ... }:

{
  imports = [ /path/to/jcrypt/jcrypt.nix ];

  programs.jcrypt = {
    enable = true;
    # src defaults to the directory containing jcrypt.nix, so no need
    # to set it unless importing from a flake input.

    mountBase   = "/mnt/crypt";
    fileManager = "nautilus";
    symlink     = true;

    vaults = {
      notes  = "~/documents/notes/other/encrypted";
      system = "~/documents/system/other/encrypted";
    };
  };
}
```

### As a flake input

Add jcrypt to your flake inputs and pass it through:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    jcrypt.url = "path:./jcrypt";
  };

  outputs = { self, nixpkgs, home-manager, jcrypt, ... }: {
    # ... your flake outputs, passing jcrypt to home-manager modules
  };
}
```

Then in your home-manager module:

```nix
{ inputs, config, pkgs, ... }:

{
  imports = [ inputs.jcrypt.homeManagerModules.default ];

  programs.jcrypt = {
    enable = true;
    # src is auto-detected from the flake input
    # ...
  };
}
```

### Module options

| Option | Type | Default | Description |
|---|---|---|---|
| `programs.jcrypt.enable` | bool | `false` | Enable jcrypt |
| `programs.jcrypt.src` | path | `./.` | Source tree (auto-detected when in the same directory) |
| `programs.jcrypt.mountBase` | string | `"/mnt/crypt"` | Base directory for mount points |
| `programs.jcrypt.fileManager` | string | `"xdg-open"` | File manager for `--open` |
| `programs.jcrypt.symlink` | bool | `false` | Create sibling `decrypted` symlinks |
| `programs.jcrypt.vaults` | attribute set | `{}` | Vault name → encrypted path mapping |

See also `jcrypt-example.nix` in this repo for a complete working example.

## Dependencies

- `gocryptfs` — must be on `$PATH`
- `fusermount` — part of the `fuse` package, used for unmounting
- A file manager (default: `xdg-open`) — only needed with `--open`