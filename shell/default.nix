{ system, ... }:
{
  imports =
    [
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
      ./programs/ai
      ./programs/direnv
      ./programs/navi
    ]
    ++ (
      if system == "aarch64-darwin" then
        [
          ./programs/weechat
        ]
      else if system == "x86_64-linux" then
        [ ]
      else
        [ ]
    );
}
