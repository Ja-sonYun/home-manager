{ configDir, pkgs, ... }:
{
  home.shellAliases = {
    analyze-shell = "nix develop ${configDir}/portable/analysis -c zsh";
  };
}
