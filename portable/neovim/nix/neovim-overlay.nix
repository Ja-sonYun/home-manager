# This overlay, when applied to nixpkgs, adds the final neovim derivation to nixpkgs.
{ inputs }:
final: prev:
with final.pkgs.lib;
let
  pkgs = final;

  # Use this to create a plugin from a flake input
  mkNvimPlugin =
    src: pname:
    pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    };

  # Make sure we use the pinned nixpkgs instance for wrapNeovimUnstable,
  # otherwise it could have an incompatible signature when applying this overlay.
  pkgs-wrapNeovim = inputs.nixpkgs.legacyPackages.${pkgs.system};

  # This is the helper function that builds the Neovim derivation.
  mkNeovim = pkgs.callPackage ./mkNeovim.nix { inherit pkgs-wrapNeovim; };

  # A plugin can either be a package or an attrset, such as
  # { plugin = <plugin>; # the package, e.g. pkgs.vimPlugins.nvim-cmp
  #   config = <config>; # String; a config that will be loaded with the plugin
  #   # Boolean; Whether to automatically load the plugin as a 'start' plugin,
  #   # or as an 'opt' plugin, that can be loaded with `:packadd!`
  #   optional = <true|false>; # Default: false
  #   ...
  # }
  all-plugins = with pkgs.vimPlugins; [
    nvim-cmp
    cmp_luasnip
    cmp-nvim-lsp
    plenary-nvim

    nvim-treesitter.withAllGrammars
    nvim-treesitter-textobjects
    nvim-ts-context-commentstring

    vim-eunuch
    vim-commentary
    vim-tmux-navigator
    vim-fugitive
    tagbar
    harpoon2
    rainbow-delimiters-nvim
    vim-surround

    octo-nvim
    telescope-nvim
    fzf-lua

    (mkNvimPlugin inputs.copilot-vim "copilot.nvim")
    (mkNvimPlugin inputs.fzf-vim "fzf.vim")
    (mkNvimPlugin inputs.fzf "fzf")
    (mkNvimPlugin inputs.nui-nvim "nui.nvim")
    (mkNvimPlugin inputs.nvim-web-devicons-nvim "nvim-web-devicons")
    (mkNvimPlugin inputs.gitsigns-nvim "gitsigns.nvim")
    (mkNvimPlugin inputs.conform-nvim "conform.nvim")
    (mkNvimPlugin inputs.vim-rooter "vim-rooter")
    (mkNvimPlugin inputs.toggleterm-nvim "toggleterm.nvim")
    (mkNvimPlugin inputs.nvim-spider "nvim-spider")
    (mkNvimPlugin inputs.fidget-nvim "fidget.nvim")
  ];

  extraPackages = with pkgs; [
    git
    cacert
    ripgrep
    gh

    # Required packages
    nodejs_20 # For copilot

    # Language servers
    lua-language-server
    nil # nix LSP
    pyright
    rust-analyzer
    rustfmt
    terraform-ls
    typescript-language-server
    gopls
    bash-language-server
    yaml-language-server
    ccls
    marksman

    # Formatters
    stylua
    nodePackages.prettier
    python312Packages.black
    python312Packages.isort
    shellcheck
    clang-tools
    shfmt
    markdownlint-cli2
    nixfmt-rfc-style

    # Stdlibs
    go
    rustPackages.cargo
    rustPackages.rustc
  ];
in
{
  # This is the neovim derivation
  # returned by the overlay
  nvim-pkg = mkNeovim {
    plugins = all-plugins;
    inherit extraPackages;
  };

  # This is meant to be used within a devshell.
  # Instead of loading the lua Neovim configuration from
  # the Nix store, it is loaded from $XDG_CONFIG_HOME/nvim-dev
  nvim-dev = mkNeovim {
    plugins = all-plugins;
    inherit extraPackages;
    appName = "nvim-dev";
    wrapRc = false;
  };

  # This can be symlinked in the devShell's shellHook
  nvim-luarc-json = final.mk-luarc-json {
    plugins = all-plugins;
  };

  # You can add as many derivations as you like.
  # Use `ignoreConfigRegexes` to filter out config
  # files you would not like to include.
  #
  # For example:
  #
  # nvim-pkg-no-telescope = mkNeovim {
  #   plugins = [];
  #   ignoreConfigRegexes = [
  #     "^plugin/telescope.lua"
  #     "^ftplugin/.*.lua"
  #   ];
  #   inherit extraPackages;
  # };
}
