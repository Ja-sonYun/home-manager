{ cacheDir
, pkgs
, config
, ...
}:
{
  launchd.user.agents.sketchybar = {
    path = with pkgs; [
      gh
      sketchybar
      config.environment.systemPath
      flock
      yabai
      taskwarrior3
      icalPal
    ];

    environment = {
      SKETCHYBAR_CONFIG_DIR = toString ./config;
    };

    serviceConfig = {
      ProgramArguments = [
        "${pkgs.sketchybar}/bin/sketchybar"
        "-c"
        (toString ./sketchybarrc)
      ];

      KeepAlive = true;
      RunAtLoad = true;

      StandardOutPath = "${cacheDir}/logs/sketchybar.out.log";
      StandardErrorPath = "${cacheDir}/logs/sketchybar.err.log";
    };
  };
}
