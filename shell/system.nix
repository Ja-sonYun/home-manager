{
  pkgs,
  configDir,
  ...
}:
{
  imports = [
    ./secrets
  ];

  environment.shells = [
    pkgs.zsh
  ];

  time.timeZone = "Asia/Tokyo";

  environment.variables.EDITOR = "nvim";
  environment.variables.FLAKE_TEMPLATES_DIR = "${configDir}/templates";
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
