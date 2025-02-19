{ cacheDir, pkgs, config, ... }: {
  launchd.user.agents.yabai = {
    path = with pkgs; [
      yabai
      config.environment.systemPath
    ];

    serviceConfig = {
      ProgramArguments = [
        "${pkgs.yabai}/bin/yabai"
        "-c"
        (toString ./yabairc)
      ];

      KeepAlive = true;
      RunAtLoad = true;

      StandardOutPath = "${cacheDir}/logs/yabai.out.log";
      StandardErrorPath = "${cacheDir}/logs/yabai.err.log";
    };
  };
}
