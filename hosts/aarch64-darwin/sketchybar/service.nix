{
  cacheDir,
  pkgs,
  config,
  userhome,
  ...
}:
let
  # Copied from ../icalPal/default.nix
  gemHome = "${userhome}/.local/share/gem/ruby/3.4.0";
  icalPalHome = "${gemHome}/gems/icalPal-3.7.0";
in
{
  launchd.user.agents.sketchybar = {
    path = with pkgs; [
      gh
      sketchybar
      config.environment.systemPath
      flock
      yabai
      taskwarrior3
      "${icalPalHome}/bin"
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
