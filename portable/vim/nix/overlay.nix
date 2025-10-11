{
  inputs,
  vim ? null,

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
let
  pkgs = final;

  mkVimPlugin =
    src: pname:
    (pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate or "0";
    }).overrideAttrs
      (_: {
        doCheck = false;
      });

  # Effective vim base. If a custom 'vim' is passed, use it. Else pkgs.vim-full.
  effectiveVim = if vim == null then pkgs.vim-full else vim;

  allPlugins =
    with pkgs.vimPlugins;
    [
      # Plugins from nixpkgs
      fzf-vim
      vim-tmux-navigator
      vim-commentary
      vim-surround
      vim-repeat
      vim-abolish
      vim-fugitive
      vim-rhubarb
      undotree
      tagbar
    ]
    ++ [
      # Plugins from flake inputs
      (mkVimPlugin inputs.vim-lsp "vim-lsp")
    ]
    ++ pkgs.lib.optionals config.useCopilot [
      copilot-vim
    ];

  # TODO:
  myPluginsFromGit = [ ];

  # Aggregate plugin set for packaged Vim
  packagedPlugins = allPlugins ++ myPluginsFromGit;

  commonPackages =
    with pkgs;
    [
      git
      cacert
      ripgrep
      gh
      fzf
      universal-ctags
      gnumake
      gawk
    ]
    ++ pkgs.lib.optionals config.useCopilot [ pkgs.nodejs_22 ];

  makefilePackagesOpt = pkgs.lib.optionals config.useMakefile (
    with pkgs;
    [
      mbake
    ]
  );

  nodePackagesOpt = pkgs.lib.optionals config.useNode (
    with pkgs;
    [
      nodePackages.prettier
      typescript-language-server
    ]
  );

  pythonPackagesOpt = pkgs.lib.optionals config.usePython (
    with pkgs;
    [
      python312Packages.black
      python312Packages.isort
      pyright
    ]
  );

  luaPackagesOpt = pkgs.lib.optionals config.useLua (
    with pkgs;
    [
      lua-language-server
      stylua
    ]
  );

  rustPackagesOpt = pkgs.lib.optionals config.useRust (
    with pkgs;
    [
      rust-analyzer
      rustfmt
      rustPackages.cargo
      rustPackages.rustc
    ]
  );

  nixPackagesOpt = pkgs.lib.optionals config.useNix (
    with pkgs;
    [
      nixfmt-rfc-style
      nil
    ]
  );

  terraformPackagesOpt = pkgs.lib.optionals config.useTerraform (
    with pkgs;
    [
      terraform
      terraform-ls
    ]
  );

  goPackagesOpt = pkgs.lib.optionals config.useGo (
    with pkgs;
    [
      gopls
      go
    ]
  );

  cxxPackagesOpt = pkgs.lib.optionals config.useCxx (
    with pkgs;
    [
      clang-tools
    ]
  );

  markdownPackagesOpt = pkgs.lib.optionals config.useMarkdown (
    with pkgs;
    [
      # marksman
      nodePackages.prettier
    ]
  );

  shellPackagesOpt = pkgs.lib.optionals config.useShell (
    with pkgs;
    [
      shellcheck
      shfmt
      bash-language-server
    ]
  );

  rubyPackagesOpt = pkgs.lib.optionals config.useRuby (
    with pkgs;
    [
      ruby
      ruby-lsp
      rufo
    ]
  );

  swiftPackagesOpt = pkgs.lib.optionals config.useSwift (
    with pkgs;
    [
      swift-format
    ]
  );

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

  mkRC =
    {
      cfgDir,
      dev ? false,
    }:
    ''
      " Load user runtime
      set runtimepath^=${cfgDir}
      set runtimepath+=${cfgDir}/after
      source ${cfgDir}/vimrc

      " Optional development packpath for local plugins
      ${pkgs.lib.optionalString dev ''
        set packpath^=~/.vim-plugins/site
      ''}
    '';

  mkVim =
    {
      name,
      cfgDir,
      plugins,
      paths ? [ ],
      dev ? false,
    }:
    let
      vimPkg =
        (effectiveVim.customize {
          inherit name;
          vimrcConfig = {
            customRC = mkRC { inherit cfgDir dev; };
            packages.myplugins = {
              start = plugins;
              opt = [ ];
            };
          };
        }).overrideAttrs
          (old: {
            meta = (old.meta or { }) // {
              mainProgram = "vim";
            };
          });
    in
    pkgs.buildEnv {
      inherit name;
      paths = [ vimPkg ] ++ paths;
    };

  vimPkg = mkVim {
    name = "vim-pkg";
    cfgDir = toString ./vim;
    plugins = packagedPlugins;
    paths = extraPackages;
    dev = false;
  };

  vimDev = mkVim {
    name = "vim-dev";
    # Expect a live config in ~/.config/vim-dev for rapid iteration.
    cfgDir = "~/.config/vim-dev";
    plugins = allPlugins;
    paths = extraPackages;
    dev = true;
  };
in
{
  vim-pkg = vimPkg;
  vim-dev = vimDev;
}
