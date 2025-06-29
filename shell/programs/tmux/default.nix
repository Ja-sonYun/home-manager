{
  pkgs,
  system,
  ...
}:
let
  tmux-menu = pkgs.lib.cargo.mkCargoGlobalPackageDerivation {
    inherit pkgs system;
    name = "tmux-menu";
    rustEdition = "2021";
    outputHash = "sha256-ZidGqvTs+CDDGTvKXm7ZhWOuUQjVYYs8YWxVTWkkKiw=";
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
