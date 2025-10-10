{
  description = "Neovim derivation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    gen-luarc.url = "github:mrcjkb/nix-gen-luarc-json";

    # Vim plugins
    copilot-vim = {
      url = "github:github/copilot.vim";
      flake = false;
    };
    fzf-vim = {
      url = "github:junegunn/fzf.vim";
      flake = false;
    };
    fzf = {
      url = "github:junegunn/fzf";
      flake = false;
    };
    gitsigns-nvim = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };

    nvim-autocomp = {
      url = "github:Ja-sonYun/nvim-autocomp";
      flake = false;
    };
    nvim-formatter = {
      url = "github:Ja-sonYun/nvim-formatter";
      flake = false;
    };
    nvim-rooter = {
      url = "github:Ja-sonYun/nvim-rooter";
      flake = false;
    };
    nvim-wordnav = {
      url = "github:Ja-sonYun/nvim-wordnav";
      flake = false;
    };
    nvim-bnqf = {
      url = "github:Ja-sonYun/nvim-bnqf";
      flake = false;
    };
    nvim-macroedit = {
      url = "github:Ja-sonYun/nvim-macroedit";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    let
      systems = builtins.attrNames nixpkgs.legacyPackages;

      boolEnv =
        name: default:
        let
          v = builtins.getEnv name;
        in
        if v == "" then default else (v == "1" || v == "true" || v == "TRUE" || v == "yes" || v == "on");

      explicitOptions =
        let
          envKeys = [
            "USE_GO"
            "USE_RUST"
            "USE_PYTHON"
            "USE_NODE"
            "USE_LUA"
            "USE_NIX"
            "USE_TERRAFORM"
            "USE_CXX"
            "USE_MARKDOWN"
            "USE_SHELL"
            "USE_RUBY"
            "USE_SWIFT"
            "USE_MAKEFILE"
            "USE_COPILOT"
          ];
          hasValue = key: builtins.getEnv key != "";
        in
        builtins.any hasValue envKeys;

      config =
        if explicitOptions then
          {
            useGo = boolEnv "USE_GO" false;
            useRust = boolEnv "USE_RUST" false;
            usePython = boolEnv "USE_PYTHON" false;
            useNode = boolEnv "USE_NODE" false;
            useLua = boolEnv "USE_LUA" false;
            useNix = boolEnv "USE_NIX" false;
            useTerraform = boolEnv "USE_TERRAFORM" false;
            useCxx = boolEnv "USE_CXX" false;
            useMarkdown = boolEnv "USE_MARKDOWN" false;
            useShell = boolEnv "USE_SHELL" false;
            useRuby = boolEnv "USE_RUBY" false;
            useSwift = boolEnv "USE_SWIFT" false;
            useMakefile = boolEnv "USE_MAKEFILE" false;
            useCopilot = boolEnv "USE_COPILOT" false;
          }
        else
          {
            useGo = true;
            useRust = true;
            usePython = true;
            useNode = true;
            useLua = true;
            useNix = true;
            useTerraform = true;
            useCxx = true;
            useMarkdown = false; # TODO: Marksman doesn't have cache yet
            useShell = true;
            useRuby = true;
            useSwift = true;
            useMakefile = true;
            useCopilot = true;
          };

      # This is where the Neovim derivation is built.
      neovim-overlay = import ./nix/neovim-overlay.nix {
        inherit inputs config;
        # neovim = {
        #   version = "0.11.0";
        #   sha256 = "sha256-UVMRHqyq3AP9sV79EkPUZnVkj0FpbS+XDPPOppp2yFE=";
        #   mkBuildInputs =
        #     final: with final; [
        #       utf8proc
        #     ];
        # };
      };
    in
    flake-utils.lib.eachSystem systems (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            neovim-overlay
            inputs.gen-luarc.overlays.default
          ];
          config.allowUnfree = true;
        };
        shell = pkgs.mkShell {
          name = "nvim-devShell";
          buildInputs = with pkgs; [
            # Tools for Lua and Nix development, useful for editing files in this repo
            lua-language-server
            nil
            luajit
            luajitPackages.luacheck
            luajitPackages.luarocks_bootstrap
            stylua

            nvim-dev
          ];
          shellHook = ''
            ln -fs ${pkgs.nvim-luarc-json} .luarc.json
            # allow quick iteration of lua configs
            ln -Tfns $PWD/nvim ~/.config/nvim-dev

            # link plugins for development
            mkdir -p ~/.config/nvim-plugins/site/pack/dev/start
            for p in "$PWD"/plugins/*; do
              ln -sfn "$p" ~/.config/nvim-plugins/site/pack/dev/start/$(basename "$p")
            done

            alias vi='nvim-dev' vim='nvim-dev'
          '';
        };
      in
      {
        packages = rec {
          default = nvim;
          nvim = pkgs.nvim-pkg;
          nvim-dev = pkgs.nvim-dev;
        };
        devShells = {
          default = shell;
        };
      }
    )
    // {
      overlays.default = neovim-overlay;
    };
}
