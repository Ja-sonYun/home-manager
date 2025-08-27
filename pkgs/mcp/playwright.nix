{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "playwright-mcp";
  packages = [
    "@playwright/mcp@0.0.35"
  ];
  exposedBinaries = [
    "mcp-server-playwright"
  ];
  outputHash = "sha256-3h6f1IO+CUk3TeHJcvK5C3LAuxA351tmb5l/W98wCRU=";
  postInstall = ''
    binary_path=$(readlink -f $out/bin/mcp-server-playwright)
    rm -f $out/bin/mcp-server-playwright
    cat > $out/bin/mcp-server-playwright <<EOF
    #!${pkgs.runtimeShell}
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
    exec $binary_path "\$@"
    EOF
    chmod +x $out/bin/mcp-server-playwright
  '';
}
