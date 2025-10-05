{ pkgs, ... }:

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "browser-use";
  pythonVersion = "311";
  packages = [
    "'browser-use[cli]'==0.7.3"
  ];
  exposedBinaries = [
    "browser-use"
  ];
  outputHash = "sha256-uRdBcyNb12aj/yD0mUO+mU4GhjYQroti6ZkDtKAHuwg=";
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
