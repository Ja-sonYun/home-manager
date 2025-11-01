#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <relative-path-to-nix-file> [s3://cache-url]" >&2
    exit 1
fi

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
TARGET_INPUT=$1
# CACHE_URL=${2:-}

if [[ "$TARGET_INPUT" = /* ]]; then
    TARGET_PATH="$TARGET_INPUT"
else
    TARGET_PATH="$ROOT_DIR/$TARGET_INPUT"
fi

if [[ ! -f "$TARGET_PATH" ]]; then
    echo "Target file not found: $TARGET_PATH" >&2
    exit 1
fi

# Use your flake context to preserve overlays, exactly like your hash updater
BUILD_EXPR=$(
    cat <<EXPR
let
  flake = builtins.getFlake (toString ${ROOT_DIR});
  pkgs = import flake.inputs.nixpkgs {
    system = builtins.currentSystem;
    overlays = flake.overlays;
    config.allowUnfree = true;
  };
in pkgs.callPackage ${TARGET_PATH} {}
EXPR
)

echo "[1/3] Building derivation from ${TARGET_PATH}"
OUT_PATH=$(nix build --extra-experimental-features 'nix-command flakes' \
    --impure --expr "$BUILD_EXPR" --print-out-paths)

echo "[2/3] Build done: $OUT_PATH"

# if [[ -n "$CACHE_URL" ]]; then
#     echo "[3/3] Uploading to cache: $CACHE_URL"
#     nix copy --to "$CACHE_URL" --recursive "$OUT_PATH"
#     echo "Upload complete."
# else
#     echo "No cache URL provided; skipping upload."
# fi
