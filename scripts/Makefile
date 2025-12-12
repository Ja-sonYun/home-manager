MAKEFLAGS += --no-print-directory

include ../.mkutils/colors.mk
include ../.mkutils/args.mk

HELP_PROJECT_NAME := Amber Scripts
HELP_WIDTH := 20

include ../.mkutils/help.mk

AMBER := nix run nixpkgs\#amber-lang --

SCRIPTS := update-versions build-pkg

##@ Build

build:: $(SCRIPTS) ## Compile all amber scripts

update-versions:: ## Compile update-versions
	@$(AMBER) build src/update-versions/main.ab $@
	$(call print_success,"Built $@")

build-pkg:: ## Compile build-pkg
	@$(AMBER) build src/build-pkg/main.ab $@
	$(call print_success,"Built $@")

check:: ## Check amber syntax for all scripts
	@$(AMBER) check src/update-versions/main.ab
	@$(AMBER) check src/build-pkg/main.ab
	$(call print_success,"Syntax OK")

clean:: ## Remove compiled scripts
	@rm -f $(SCRIPTS)
	$(call print_success,"Cleaned")

##@ Run

run-update-versions:: ## Run update-versions directly
	@$(AMBER) run src/update-versions/main.ab -- $(RUN_ARGS)

run-build-pkg:: ## Run build-pkg directly
	@$(AMBER) run src/build-pkg/main.ab -- $(RUN_ARGS)
