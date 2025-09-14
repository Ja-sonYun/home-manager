{ lib, ... }:
let
  packageBrews = [ ];

  allBrews = lib.concatMap (pkg: pkg.homebrew.brews or [ ]) packageBrews;
  allCasks = lib.concatMap (pkg: pkg.homebrew.casks or [ ]) packageBrews;
  allTaps = lib.concatMap (pkg: pkg.homebrew.taps or [ ]) packageBrews;
in
{
  homebrew = {
    enable = true;
    global = {
      autoUpdate = false;
    };
    # will not be uninstalled when removed
    masApps = {
      # Xcode = 497799835;
      # Transporter = 1450874784;
      # VN = 1494451650;
    };
    onActivation = {
      # "zap" removes manually installed brews and casks
      cleanup = "zap";
      autoUpdate = false;
      upgrade = false;
    };
    brews = [
      "keith/formulae/reminders-cli"
      "localstack/tap/localstack-cli"
      "qemu"
    ]
    ++ allBrews;
    casks = [
      "ghostty"
      "aldente"
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

      "vagrant"
      "orbstack"
      "alfred"
      "aldente"
      "cleanshot"

      "hyprnote"

      # TODO: Move to nix
      "macfuse"
    ]
    ++ allCasks;
    taps = [
      "keith/formulae"
      "localstack/tap"
      "fastrepl/hyprnote"
    ]
    ++ allTaps;
  };
}
