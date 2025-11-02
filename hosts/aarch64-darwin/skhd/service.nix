{ cacheDir, pkgs, config, ... }:
let
  originalConfigFile = builtins.readFile ./skhdrc;
  # NOTE: skhd spawn a new shell on running command.
  # This will cause a problem when using PATH defined in plist.
  # So just replace the path directly
  configFileContent = builtins.replaceStrings
    [ "%yabai%" "%skhd%" "%inputSourceSelector%" ]
    [ "${pkgs.yabai}/bin/yabai" "${pkgs.skhd}/bin/skhd" "${pkgs.inputSourceSelector}/bin/InputSourceSelector" ]
    originalConfigFile;
  configFile = pkgs.writeScript "skhdrc" configFileContent;
in
{
  launchd.user.agents.skhd = {
    path = with pkgs; [
      skhd
      config.environment.systemPath
    ];

    serviceConfig = {
      ProgramArguments = [
        "${pkgs.skhd}/bin/skhd"
        "-c"
        (toString configFile)
      ];

      KeepAlive = true;
      RunAtLoad = true;

      StandardOutPath = "${cacheDir}/logs/skhd.out.log";
      StandardErrorPath = "${cacheDir}/logs/skhd.err.log";
    };
  };
}
