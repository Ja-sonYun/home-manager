.DEFAULT_GOAL := deploy

HOSTNAME := $(shell hostname -s)
SYSTEM := $(shell uname -s)

ifeq ($(shell command -v nom),)
  NIX := nix
else
  NIX := nom
endif

nix-features-flag := --extra-experimental-features 'nix-command flakes'

ifdef TRACE
NIX_TRACE_ARGS := --show-trace
endif

update:
	# cd ./portable/neovim && nix flake update
	nix flake update

add:
	git add .

lock: add
	nix flake lock --update-input neovim $(nix-features-flag)

ifeq ($(SYSTEM),Darwin)
build: add lock
	$(NIX) build .#darwinConfigurations.$(HOSTNAME).system $(nix-features-flag) $(NIX_TRACE_ARGS)

deploy: build
	sudo ./result/sw/bin/darwin-rebuild switch --flake .#$(HOSTNAME) $(NIX_TRACE_ARGS)

show-derivations:
	nix show-derivation .#darwinConfigurations.$(HOSTNAME).system $(nix-features-flag)
endif

ifeq ($(SYSTEM),Linux)
install:
	sh <(curl -L https://nixos.org/nix/install) --daemon

deploy: add lock
	nix run nixpkgs#home-manager $(nix-features-flag) -- \
	switch --flake .#$(HOSTNAME) $(NIX_TRACE_ARGS) $(nix-features-flag)
endif

clean:
	nix store gc --debug
	nix-collect-garbage -d
