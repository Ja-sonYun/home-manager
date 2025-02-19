{ config, pkgs, lib, ... }:

with lib;

let
  nodeAttrs = config.programs.node;
in
{
  ##############################
  # Module Options Definition
  ##############################
  options.programs.node = mkOption {
    type = types.attrs;
    default = { };
    description = ''
      Configuration for Node.js-managed CLI tools.
      Each attribute is a tool name with a definition containing:
      - version: Version to install (null for the latest from npm).
    '';
  };

  ##########################################
  # Configuration: Activate if packages exist
  ##########################################
  config =
    let
      # Generate the activation script for adding/updating packages
      generateInstallScript = packageName:
        let
          pkgConf = nodeAttrs.${packageName};
          versionArg = if pkgConf.version == null then "" else "@" + pkgConf.version;
        in
        ''
          if npm list -g --depth=0 | grep -q "${packageName}${versionArg}"; then
            echo "   Skipping ${packageName}${versionArg}: already installed"
          else
            echo "   Installing ${packageName}${versionArg} globally"
            npm install -g "${packageName}${versionArg}" || true
          fi
        '';

      # Generate the removal script for unused packages
      generateRemoveScript = packageName:
        ''
          echo "   Removing unused package ${packageName}"
          npm uninstall -g "${packageName}" || true
        '';

      # Generate the final activation script
      generateActivationScript =
        let
          definedPackages = attrNames nodeAttrs;
        in
        ''
          if command -v npm > /dev/null; then
            echo ">> Listing installed npm packages"
            installedPackages=$(npm list -g --depth=0 --json | jq -r '.dependencies | keys[]')

            # Remove unused packages
            for packageName in $installedPackages; do
              if ! echo "${toString definedPackages}" | grep -q "$packageName"; then
                echo "Removing $packageName"
                npm uninstall -g "$packageName"
              fi
            done

            # Add/update defined packages
            ${concatStringsSep "\n" (map generateInstallScript definedPackages)}
          else
            echo "Error: npm is not installed or not found in PATH"
          fi
        '';
    in
    {
      # Ensure Node.js and npm are installed in the system
      home.packages = [ pkgs.nodejs ];

      # Activation script for Node.js
      home.activation.node = lib.hm.dag.entryAfter [ "writeBoundary" ] generateActivationScript;
    };
}
