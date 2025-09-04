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
      jankyborders-local
      config.environment.systemPath
    ];

    serviceConfig = {
      ProgramArguments = [
        "${pkgs.jankyborders}/bin/borders"
      ]
      ++ (optionalArg "style" "round")
      ++ (optionalArg "width" "3.0")
      ++ (optionalArg "hidpi" "off")
      ++ (optionalArg "active_color" "0xff6600cc")
      ++ (optionalArg "inactive_color" "0xffa0a0a0");

      KeepAlive = true;
      RunAtLoad = true;

      StandardOutPath = "${cacheDir}/logs/borders.out.log";
      StandardErrorPath = "${cacheDir}/logs/borders.err.log";
    };
  };
}
