{ cacheDir, pkgs, lib, config, ... }:
let
  optionalArg = arg: value:
    if value != null && value != ""
    then
      if lib.isList value
      then lib.map (val: "${arg}=${val}") value
      else [ "${arg}=${value}" ]
    else [ ];
in
{
  launchd.user.agents.jankyborders = {
    path = with pkgs; [
      jankyborders
      config.environment.systemPath
    ];

    serviceConfig = {
      ProgramArguments = [
        "${pkgs.jankyborders}/bin/borders"
      ]
      ++ (optionalArg "style" "round")
      ++ (optionalArg "width" "2.0")
      ++ (optionalArg "hidpi" "on")
      ++ (optionalArg "ax_focus" "off")
      ++ (optionalArg "active_color" "0xff6600cc")
      ++ (optionalArg "background_color" "0xffa0a0a0")
      ++ (optionalArg "inactive_color" "0xffa0a0a0");

      KeepAlive = true;
      RunAtLoad = true;

      StandardOutPath = "${cacheDir}/logs/borders.out.log";
      StandardErrorPath = "${cacheDir}/logs/borders.err.log";
    };
  };
}
