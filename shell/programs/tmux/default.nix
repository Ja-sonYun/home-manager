{ pkgs, ... }:
{
  imports = [
    ../../../modules/cargo
  ];
  home.packages = with pkgs; [
    tmux
    pstree
  ];
  home.file.tmuxconf = {
    target = ".tmux.conf";
    source = toString ./tmux.conf;
  };
  home.sessionVariables.TMUX_CONFIG = toString ./config;

  programs.cargo.tmux-menu = {
    version = null;
    # ldpkgs = [ pkgs.libiconv ];
  };

  home.shellAliases = {
    tm = toString ./config/scripts/tmux;
  };
}
