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
    nui-nvim = {
      url = "github:MunifTanjim/nui.nvim";
      flake = false;
    };
    nvim-web-devicons-nvim = {
      url = "github:nvim-tree/nvim-web-devicons";
      flake = false;
    };
    gitsigns-nvim = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    conform-nvim = {
      url = "github:stevearc/conform.nvim";
      flake = false;
    };
    vim-rooter = {
      url = "github:airblade/vim-rooter";
      flake = false;
    };
    toggleterm-nvim = {
      url = "github:akinsho/toggleterm.nvim";
      flake = false;
    };
    nvim-spider = {
      url = "github:chrisgrieser/nvim-spider";
      flake = false;
    };
    fidget-nvim = {
      url = "github:j-hui/fidget.nvim";
      flake = false;
    };
    quicker-nvim = {
      url = "github:stevearc/quicker.nvim";
      flake = false;
    };
    winresizer = {
      url = "github:simeji/winresizer";
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

      # This is where the Neovim derivation is built.
      neovim-overlay = import ./nix/neovim-overlay.nix {
        inherit inputs;
        # neovim = {
        #   version = "0.11.0";
        #   sha256 = "sha256-UVMRHqyq3AP9sV79EkPUZnVkj0FpbS+XDPPOppp2yFE=";
        #   mkBuildInputs =
        #     final: with final; [
        #       utf8proc
        #     ];
        # };
        config = {
          useGo = true;
          useRust = true;
          usePython = true;
          useNode = true;
          useLua = true;
          useNix = true;
          useTerraform = true;
          useCxx = true;
          useMarkdown = true;
          useShell = true;
          useRuby = true;
          useSwift = true;
        };
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
            stylua
            luajitPackages.luacheck
            nvim-dev
          ];
          shellHook = ''
            ln -fs ${pkgs.nvim-luarc-json} .luarc.json
            # allow quick iteration of lua configs
            ln -Tfns $PWD/nvim ~/.config/nvim-dev
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
