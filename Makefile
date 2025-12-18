.DEFAULT_GOAL := deploy

HOSTNAME := $(shell hostname -s)
SYSTEM := $(shell uname -s)

ifeq ($(shell command -v nom),)
  NIX := nix
else
  NIX := nom
endif

NIX_CONFIG ?= experimental-features = nix-command flakes
export NIX_CONFIG

ifdef TRACE
NIX_TRACE_ARGS := --show-trace
endif

update-vim:
	cd ./portable/vim && nix flake update

update-raw: update-vim
	nix flake update

update-pkgs: update-raw
	./scripts/update-versions

update:
	@sh -c 'set -eu; \
	orig_ulimit=$$(ulimit -n || echo 0); \
	trap "ulimit -n $$orig_ulimit >/dev/null 2>&1 || true" EXIT; \
	if [ "$$orig_ulimit" -lt 65536 ] 2>/dev/null; then ulimit -n 65536 || true; fi; \
		$(MAKE) update-raw update-pkgs'

add:
	git add .

lock: add
	nix flake update vim
	nix flake update server

ifeq ($(SYSTEM),Darwin)
build: add lock
	$(NIX) build .#darwinConfigurations.$(HOSTNAME).system $(NIX_TRACE_ARGS)

deploy: build
	nix run nixpkgs#nh darwin switch .#darwinConfigurations.$(HOSTNAME)

show-derivations:
	nix show-derivation .#darwinConfigurations.$(HOSTNAME).system
endif

ifeq ($(SYSTEM),Linux)
install:
	sh <(curl -L https://nixos.org/nix/install) --daemon

deploy: add lock
	nix run nixpkgs#nh home switch .#homeConfigurations.$(HOSTNAME)
endif

clean:
	nix run nixpkgs#nh clean
