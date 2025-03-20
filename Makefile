.DEFAULT_GOAL := deploy

HOSTNAME := $(shell hostname -s)
SYSTEM := $(shell uname -s)

nix-features-flag := --extra-experimental-features 'nix-command flakes'

ifdef TRACE
NIX_TRACE_ARGS := --show-trace
endif

add:
	git add .

lock: add
	nix flake lock --update-input neovim $(nix-features-flag)

ifeq ($(SYSTEM),Darwin)
build: add lock
	nix build .#darwinConfigurations.$(HOSTNAME).system $(nix-features-flag) $(NIX_TRACE_ARGS)

deploy: build
	./result/sw/bin/darwin-rebuild switch --flake .#$(HOSTNAME) $(NIX_TRACE_ARGS)
endif

ifeq ($(SYSTEM),Linux)
install:
	sh <(curl -L https://nixos.org/nix/install) --daemon

deploy: add lock
	nix run nixpkgs#home-manager $(nix-features-flag) -- \
		switch --flake .#$(HOSTNAME) $(NIX_TRACE_ARGS) $(nix-features-flag)
endif
