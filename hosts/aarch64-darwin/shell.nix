{ pkgs, ... }:
{
  environment.shells = [
    pkgs.zsh
  ];

  time.timeZone = "Asia/Tokyo";

  environment.variables.EDITOR = "vim";
  environment.systemPath = [ ];
  environment.systemPackages = with pkgs; [
    vim-pkg
  ];
  environment.shellAliases = {
    vi = "vim";
  };
}
