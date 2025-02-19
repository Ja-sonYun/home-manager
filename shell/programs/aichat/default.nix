{ pkgs, userhome, cacheDir, ... }: {
  home.packages = with pkgs; [
    aichat
  ];
  home.sessionVariables.AICHAT_CONFIG_DIR = toString ./config/aichat;
  home.sessionVariables.AICHAT_PLATFORM = "openai";
  home.sessionVariables.AICHAT_ENV_FILE = "${userhome}/.env";
  home.sessionVariables.AICHAT_SESSIONS_DIR = "${cacheDir}/aichat";


  home.file.aichatconf = {
    recursive = true;
    target = ".config/aichat";
    source = toString ./config/aichat;
  };
}
