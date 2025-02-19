{ ... }:
{
  imports = [
    ./zsh
    ./core

    ./programs/git
    ./programs/git/utils.nix
    ./programs/jujutsu
    ./programs/tmux
    ./programs/visidata
    ./programs/aichat
    ./programs/direnv
  ];
}
