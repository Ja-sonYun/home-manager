{ ... }: {
  programs.direnv = {
    enable = true;

    enableZshIntegration = true;
  };

  home.sessionVariables.DIRENV_WARN_TIMEOUT = "1m";
}
