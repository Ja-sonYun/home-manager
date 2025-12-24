# dotfiles

Personal system configuration using Nix Flakes, Home Manager, and nix-darwin.

## Structure

```
.
├── flake.nix       # Entry point
├── hosts/          # Host-specific configs (macOS, Linux)
├── shell/          # Shell & program configs
├── pkgs/           # Custom Nix packages
├── portable/       # Standalone flake packages
└── infra/          # Infrastructure code (Terraform, Ansible)
```

## Notes

**libs** - Package builders via `pkgs.lib.{npm,pip,cargo}`:
- Uses fixed-output derivations for reproducible npm/pip/cargo builds
- `./scripts/update-versions` fetches latest versions from npm/pypi, builds, and updates hashes

**portable/vim** - Standalone neovim with selective language support:
```sh
nix run 'github:Ja-sonYun/dotfiles?dir=portable/vim'

# With options to skip languages for faster builds
USE_GO=1 USE_RUST=1 USE_COPILOT=1 nix run ... --impure
```

## Setup

```sh
git clone https://github.com/Ja-sonYun/dotfiles.git
cd dotfiles
git submodule update --init --recursive
```

## Usage

```sh
make deploy  # Apply configuration
make update  # Update flakes and packages
```
