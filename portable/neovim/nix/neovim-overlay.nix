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
    useSwift = false;
    useMakefile = false;
    useCopilot = false;
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

  all-plugins =
    with pkgs.vimPlugins;
    [
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      nvim-ts-context-commentstring

      marks-nvim

      vim-tmux-navigator
      vim-commentary
      vim-fugitive
      vim-dispatch
      vim-repeat
      vim-abolish
      vim-rhubarb
      vim-surround
      undotree
      tagbar

      (mkNvimPlugin inputs.fzf "fzf")
      (mkNvimPlugin inputs.fzf-vim "fzf.vim")
      (mkNvimPlugin inputs.gitsigns-nvim "gitsigns.nvim")
    ]
    ++ (if config.useCopilot then [ (mkNvimPlugin inputs.copilot-vim "copilot.vim") ] else [ ]);

  my-plugins-from-git = [
    (mkNvimPlugin inputs.nvim-autocomp "nvim-autocomp")
    (mkNvimPlugin inputs.nvim-formatter "nvim-formatter")
    (mkNvimPlugin inputs.nvim-rooter "nvim-rooter")
    (mkNvimPlugin inputs.nvim-wordnav "nvim-wordnav")
  ];

  extraLuaPaths = [ ];

  commonPackages =
    with pkgs;
    [
      git
      cacert
      ripgrep
      gh
      fzf

      harper
      ctags

      gnumake

      gawk
    ]
    ++ (if config.useCopilot then [ pkgs.nodejs_22 ] else [ ]);

  makefilePackagesOpt =
    if config.useMakefile then
      with pkgs;
      [
        mbake
      ]
    else
      [ ];

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
    makefilePackagesOpt
  ];
in
{
  # This is the neovim derivation
  # returned by the overlay
  nvim-pkg = mkNeovim {
    # Load my plugins from git repos on nvim-pkg
    plugins = all-plugins ++ my-plugins-from-git;
    inherit extraPackages extraLuaPaths;
  };

  # This is meant to be used within a devshell.
  # Instead of loading the lua Neovim configuration from
  # the Nix store, it is loaded from $XDG_CONFIG_HOME/nvim-dev
  nvim-dev = mkNeovim {
    # Do not load my plugins from git repos on nvim-dev, load them from local
    plugins = all-plugins;
    inherit extraPackages extraLuaPaths;
    appName = "nvim-dev";
    wrapRc = false;
  };

  nvim-luarc-json = final.mk-luarc-json {
    plugins = all-plugins;
  };
}
