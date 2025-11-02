{ pkgs, ... }:
let
  outputHash = (import ../hash.nix)."mcp/browser-use.nix";
in

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs outputHash;
  name = "browser-use";
  pythonVersion = "311";
  packages = [
    "'browser-use[cli]'==0.7.3"
  ];
  exposedBinaries = [
    "browser-use"
  ];
  postInstall = ''
    binary_path=$(readlink -f $out/bin/browser-use)
    rm -f $out/bin/browser-use
    cat > $out/bin/browser-use <<EOF
    #!${pkgs.runtimeShell}
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
    exec $binary_path "\$@"
    EOF
    chmod +x $out/bin/browser-use
  '';
}
