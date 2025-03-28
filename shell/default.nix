{ ... }:
{
  imports = [
    ./zsh
    ./core

    ./analysis

    ./programs/git
    ./programs/git/utils.nix
    # We'll use orbstack on macOS
    # ./programs/docker
    ./programs/jujutsu
    ./programs/tmux
    ./programs/visidata
    ./programs/aichat
    ./programs/direnv
    ./programs/weechat
  ];
}
