.DEFAULT_GOAL := deploy

HOSTNAME := $(shell hostname -s)

ifdef TRACE
NIX_TRACE_ARGS := --show-trace
endif

add:
	git add .

lock: add
	nix flake lock --update-input neovim

build: add lock
	nix build .#darwinConfigurations.$(HOSTNAME).system \
	  --extra-experimental-features 'nix-command flakes' $(NIX_TRACE_ARGS)

deploy: build
	./result/sw/bin/darwin-rebuild switch --flake .#$(HOSTNAME) $(NIX_TRACE_ARGS)
