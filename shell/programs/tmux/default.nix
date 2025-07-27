{
  pkgs,
  system,
  ...
}:
let
  tmux-menu = pkgs.lib.cargo.mkCargoGlobalPackageDerivation {
    inherit pkgs system;
    name = "tmux-menu";
    version = "0.1.14";
    rustEdition = "2021";
    outputHash = "sha256-vw7rCGjq2mElwcZ146FMPPH+yJX+wK/s/zVrcmD85pQ=";
  };
in
{
  home.packages = with pkgs; [
    tmux
    pstree
    tmux-menu
  ];
  home.file.tmuxconf = {
    target = ".tmux.conf";
    source = toString ./tmux.conf;
  };
  home.sessionVariables.TMUX_CONFIG = toString ./config;

  home.shellAliases = {
    tm = toString ./config/scripts/tmux;
  };
}
