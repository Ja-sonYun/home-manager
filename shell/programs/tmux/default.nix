{
  pkgs,
  libs,
  system,
  ...
}:
let
  tmux-menu = libs.cargo.mkCargoGlobalPackageDerivation {
    inherit pkgs system;
    name = "tmux-menu";
    rustEdition = "2021";
    outputHash = "sha256-0n0lRvati6fl07NXfpf+QHyaAibm3NGh7j1Lr6U1qfc=";
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
