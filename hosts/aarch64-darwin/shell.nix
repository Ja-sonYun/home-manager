{ pkgs, ... }:
{
  environment.shells = [
    pkgs.zsh
  ];

  time.timeZone = "Asia/Tokyo";

  environment.variables.EDITOR = "nvim";
  environment.systemPath = [ ];
  environment.systemPackages = with pkgs; [
    git
    nvim-pkg
  ];
  environment.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };
}
