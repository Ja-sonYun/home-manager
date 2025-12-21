{ cacheDir
, pkgs
, config
, ...
}:
let
  originalConfigFile = builtins.readFile ./yabairc;
  configFileContent =
    builtins.replaceStrings [ "%sketchybar%" ] [ "${pkgs.sketchybar}/bin/sketchybar" ]
      originalConfigFile;
  configFile = pkgs.writeScript "yabairc" configFileContent;
in
{
  launchd.user.agents.yabai = {
    path = with pkgs; [
      yabai
      config.environment.systemPath
    ];

    serviceConfig = {
      ProgramArguments = [
        "${pkgs.yabai}/bin/yabai"
        "-c"
        (toString configFile)
      ];

      KeepAlive = true;
      RunAtLoad = true;

      StandardOutPath = "${cacheDir}/logs/yabai.out.log";
      StandardErrorPath = "${cacheDir}/logs/yabai.err.log";
    };
  };
}
