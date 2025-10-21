# My Vim Configuration

## Usage

To see all available features, check `flake.nix`.

**With all features**

```sh
nix run 'github:Ja-sonYun/home-manager?dir=portable/vim' \
    --extra-experimental-features nix-command \
    --extra-experimental-features flakes

# or

docker run -it --rm \
  -v nix-linux-store:/nix \
  -v nix-linux-store:/root/.cache/nix \
  -v ${PWD}:/workspace \
  -w /workspace \
  nixos/nix \
  nix run 'github:Ja-sonYun/home-manager?dir=portable/vim' \
    --extra-experimental-features nix-command \
    --extra-experimental-features flakes
```

**With selected features**

```sh
USE_GO=1 USE_RUST=1 USE_COPILOT=1 \
nix run 'github:Ja-sonYun/home-manager?dir=portable/vim' --impure \
  --extra-experimental-features nix-command \
  --extra-experimental-features flakes

# or

docker run -it --rm \
  -v nix-linux-store:/nix \
  -v nix-linux-store:/root/.cache/nix \
  -v ${PWD}:/workspace \
  -w /workspace \
  -e USE_GO=1 \
  -e USE_RUST=1 \
  -e USE_COPILOT=1 \
  nixos/nix \
  nix run 'github:Ja-sonYun/home-manager?dir=portable/vim' \
    --impure \
    --extra-experimental-features nix-command \
    --extra-experimental-features flakes
```

## Development

```sh
nix develop

vi  # open vim-dev
```
