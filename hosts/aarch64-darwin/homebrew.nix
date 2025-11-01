{ lib, machine, ... }:
let
  packageBrews = [ ];

  allBrews = lib.concatMap (pkg: pkg.homebrew.brews or [ ]) packageBrews;
  allCasks = lib.concatMap (pkg: pkg.homebrew.casks or [ ]) packageBrews;
  allTaps = lib.concatMap (pkg: pkg.homebrew.taps or [ ]) packageBrews;

  brews = [
    "qemu"
    "localstack/tap/localstack-cli"
  ]
  ++ (
    if machine == "main" then
      [
        "keith/formulae/reminders-cli"
      ]
    else
      [ ]
  );

  casks = [
    "ghostty"
    "aldente"
    "vagrant"
    "orbstack"
  ]
  ++ (
    if machine == "main" then
      [
        "keycastr" # Show keystroke realtime
        "chatgpt"
        "gimp"
        "sf-symbols"
        "discord"
        "google-chrome"
        "slack"
        "appcleaner"
        "drawio"
        "iina"
        "ultimaker-cura"
        "balenaetcher"
        "basictex"
        "openvpn-connect"
        "freecad"
        "blender"
        "visual-studio-code"
        "obs"
        "pdf-expert"
        "jump"
        "utm"
        "kicad"
        "firefox"
        "raycast"

        "alfred"
        "aldente"
        "cleanshot"

        "hyprnote"

        # TODO: Move to nix
        "macfuse"
      ]
    else
      [
      ]
  );

  taps = [
    "localstack/tap"
  ]
  ++ (
    if machine == "main" then
      [
        "keith/formulae"
        "fastrepl/hyprnote"
      ]
    else
      [ ]
  );
in
{
  homebrew = {
    enable = true;
    global = {
      autoUpdate = false;
    };
    # will not be uninstalled when removed
    masApps =
      { }
      // (
        if machine == "main" then
          {
          }
        else
          {
            Amphetamine = 937984704;
          }
      );
    onActivation = {
      # "zap" removes manually installed brews and casks
      cleanup = "zap";
      autoUpdate = false;
      upgrade = false;
    };
    brews = brews ++ allBrews;
    casks = casks ++ allCasks;
    taps = taps ++ allTaps;
  };
}
