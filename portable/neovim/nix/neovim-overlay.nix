{
  inputs,
  neovim ? null,
  config ? {
    useGo = false;
    useRust = false;
    usePython = false;
    useNode = false;
    useLua = false;
    useNix = false;
    useTerraform = false;
    useCxx = false;
    useMarkdown = false;
    useShell = false;
    useRuby = false;
  },
}:
final: prev:
with final.pkgs.lib;
let
  pkgs = final;

  # Use default neovim if not provided
  effectiveNeovim = if neovim == null then pkgs.neovim else neovim;

  # Use this to create a plugin from a flake input
  mkNvimPlugin =
    src: pname:
    (pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    }).overrideAttrs
      {
        doCheck = false;
      };

  # Make sure we use the pinned nixpkgs instance for wrapNeovimUnstable,
  # otherwise it could have an incompatible signature when applying this overlay.
  pkgs-wrapNeovim =
    let
      pkgs-wrapNeovim = inputs.nixpkgs.legacyPackages.${pkgs.system};
      neovim-unwrapped = pkgs-wrapNeovim.neovim-unwrapped.overrideAttrs (
        oldAttrs:
        if effectiveNeovim ? sha256 then
          {
            version = effectiveNeovim.version;
            src = pkgs-wrapNeovim.fetchFromGitHub {
              owner = "neovim";
              repo = "neovim";
              tag = "v${version}";
              hash = effectiveNeovim.sha256;
            };
            buildInputs =
              oldAttrs.buildInputs
              ++ (if effectiveNeovim ? mkBuildInputs then effectiveNeovim.mkBuildInputs final else [ ]);
          }
        else
          { } # If no sha256, just leave the default derivation as is
      );
    in
    pkgs-wrapNeovim // { neovim-unwrapped = neovim-unwrapped; };

  # This is the helper function that builds the Neovim derivation.
  mkNeovim = pkgs.callPackage ./mkNeovim.nix { inherit pkgs-wrapNeovim; };

  all-plugins = with pkgs.vimPlugins; [
    plenary-nvim

    nvim-treesitter.withAllGrammars
    nvim-treesitter-textobjects
    nvim-ts-context-commentstring

    vim-tmux-navigator

    vim-eunuch
    vim-commentary
    vim-fugitive
    vim-dispatch
    vim-repeat
    vim-abolish
    vim-endwise
    vim-rhubarb
    vim-sleuth
    vim-surround

    tagbar
    rainbow-delimiters-nvim

    marks-nvim
    nvim-ts-autotag

    markdown-preview-nvim

    (mkNvimPlugin inputs.copilot-vim "copilot.nvim")
    (mkNvimPlugin inputs.fzf-vim "fzf.vim")
    (mkNvimPlugin inputs.fzf "fzf")
    (mkNvimPlugin inputs.nui-nvim "nui.nvim")
    (mkNvimPlugin inputs.nvim-web-devicons-nvim "nvim-web-devicons")
    (mkNvimPlugin inputs.gitsigns-nvim "gitsigns.nvim")
    (mkNvimPlugin inputs.vim-rooter "vim-rooter")
    (mkNvimPlugin inputs.toggleterm-nvim "toggleterm.nvim")
    (mkNvimPlugin inputs.nvim-spider "nvim-spider")
    (mkNvimPlugin inputs.fidget-nvim "fidget.nvim")
    (mkNvimPlugin inputs.quicker-nvim "quicker.nvim")
    (mkNvimPlugin inputs.winresizer "winresizer")
  ];

  commonPackages = with pkgs; [
    git
    cacert
    ripgrep
    gh

    # Required packages
    nodejs_22 # For copilot

    harper
    ctags

    mbake

    gawk
  ];

  nodePackagesOpt =
    if config.useNode then
      with pkgs;
      [
        nodePackages.prettier
        typescript-language-server
      ]
    else
      [ ];

  pythonPackagesOpt =
    if config.usePython then
      with pkgs;
      [
        python312Packages.black
        python312Packages.isort
        pyright
      ]
    else
      [ ];

  luaPackagesOpt =
    if config.useLua then
      with pkgs;
      [
        lua-language-server
        stylua
      ]
    else
      [ ];

  rustPackagesOpt =
    if config.useRust then
      with pkgs;
      [
        rust-analyzer
        rustfmt
        rustPackages.cargo
        rustPackages.rustc
      ]
    else
      [ ];

  nixPackagesOpt =
    if config.useNix then
      with pkgs;
      [
        nixfmt-rfc-style
        nil
      ]
    else
      [ ];

  terraformPackagesOpt =
    if config.useTerraform then
      with pkgs;
      [
        terraform
        terraform-ls
      ]
    else
      [ ];

  goPackagesOpt =
    if config.useGo then
      with pkgs;
      [
        gopls
        go
      ]
    else
      [ ];

  cxxPackagesOpt =
    if config.useCxx then
      with pkgs;
      [
        clang-tools
        ccls
      ]
    else
      [ ];

  markdownPackagesOpt =
    if config.useMarkdown then
      with pkgs;
      [
        marksman
        nodePackages.prettier
      ]
    else
      [ ];

  shellPackagesOpt =
    if config.useShell then
      with pkgs;
      [
        shellcheck
        shfmt
        bash-language-server
      ]
    else
      [ ];

  rubyPackagesOpt =
    if config.useRuby then
      with pkgs;
      [
        ruby
        ruby-lsp
        rufo
      ]
    else
      [ ];

  swiftPackagesOpt =
    if config.useSwift then
      with pkgs;
      [
        # Use sourcekit-lsp from bundled Swift toolchain
        swift-format
      ]
    else
      [ ];

  extraPackages = pkgs.lib.concatLists [
    commonPackages
    nodePackagesOpt
    pythonPackagesOpt
    luaPackagesOpt
    rustPackagesOpt
    nixPackagesOpt
    terraformPackagesOpt
    goPackagesOpt
    cxxPackagesOpt
    markdownPackagesOpt
    shellPackagesOpt
    rubyPackagesOpt
    swiftPackagesOpt
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

  nvim-luarc-json = final.mk-luarc-json {
    plugins = all-plugins;
  };
}
