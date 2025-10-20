{
  description = "Vim derivation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    vim-lsp = {
      url = "github:yegappan/lsp";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems =
        f:
        builtins.listToAttrs (
          map (system: {
            name = system;
            value = f system;
          }) systems
        );

      # env-driven toggles
      boolEnv =
        name: default:
        let
          v = builtins.getEnv name;
        in
        if v == "" then default else (v == "1" || v == "true" || v == "TRUE" || v == "yes" || v == "on");

      explicitOptions =
        let
          keys = [
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
            "USE_HARPER"
            "USE_YAML"
            "USE_VIM"
            "USE_AWK"
          ];
          hasVal = key: builtins.getEnv key != "";
        in
        builtins.any hasVal keys;

      cfg =
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
            useHarper = boolEnv "USE_HARPER" false;
            useYaml = boolEnv "USE_YAML" false;
            useVim = boolEnv "USE_VIM" false;
            useAwk = boolEnv "USE_AWK" false;
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
            useMarkdown = true;
            useShell = true;
            useRuby = true;
            useSwift = true;
            useMakefile = true;
            useCopilot = true;
            useHarper = true;
            useYaml = true;
            useVim = true;
            useAwk = true;
          };
    in
    {
      overlays.default = import ./nix/overlay.nix {
        inputs = self.inputs;
        config = cfg;
      };

      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
            config.allowUnfree = true;
          };
        in
        {
          default = pkgs.vim-pkg;
          vim = pkgs.vim-pkg;
          vim-dev = pkgs.vim-dev;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
            config.allowUnfree = true;
          };
        in
        {
          default = pkgs.mkShell {
            name = "vim-devshell";
            buildInputs = [
              pkgs.vim-dev
            ];
            shellHook = ''
              ln -Tfns "$PWD/vim" ~/.config/vim-dev

              mkdir -p ~/.config/vim-plugins/site/pack/dev/start
              for p in "$PWD"/plugins/*; do
                ln -sfn "$p" ~/.config/vim-plugins/site/pack/dev/start/$(basename "$p")
              done

              alias vi='vim-dev' vim='vim-dev'
            '';
          };
        }
      );
    };
}
