{
  cacheDir,
  pkgs,
  config,
  ...
}:
let
  # icalPal is a Ruby gem that accesses macOS calendar data
  # The Foundation and EventKit frameworks are accessed via Ruby's native extensions
  # rather than being linked directly, so we don't need to explicitly include them
  icalPal = pkgs.stdenv.mkDerivation rec {
    pname = "icalPal";
    version = "3.7.0";

    buildInputs = with pkgs; [
      ruby_3_4
      sqlite
    ];

    nativeBuildInputs = with pkgs; [
      makeWrapper
      ruby_3_4.devEnv
    ];

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      export GEM_HOME=$out/lib/ruby/gems/3.4.0
      export GEM_PATH=$GEM_HOME

      gem install icalPal -v ${version} --no-document

      makeWrapper ${pkgs.ruby_3_4}/bin/ruby $out/bin/icalPal \
        --add-flags "$GEM_HOME/gems/icalPal-${version}/bin/icalPal" \
        --set GEM_HOME "$GEM_HOME" \
        --set GEM_PATH "$GEM_HOME"
    '';
  };
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
