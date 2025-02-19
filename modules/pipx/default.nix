{ config, pkgs, lib, ... }:

with lib;

let
  pipxAttrs = config.programs.pipx;
in
{
  ##############################
  # Module Options Definition
  ##############################
  options.programs.pipx = mkOption {
    type = types.attrs;
    default = { };
    description = ''
      Configuration for pipx-managed Python CLI tools.
      Each attribute is a tool name with a definition containing:
      - version: Version to install (null for latest from PyPI).
      - pyVersion: Python version to use (e.g., "3.10", "3.11", "3.12").
    '';
  };

  ##########################################
  # Configuration: Activate if packages exist
  ##########################################
  config =
    let
      # Generate the pipx activation script for adding/updating packages
      generateInstallScript = packageName:
        let
          pkgConf = pipxAttrs.${packageName};
          versionArg = if pkgConf.version == null then "" else "==" + pkgConf.version;
          pyVersion = pkgConf.pyVersion;
          pyNoDot = replaceStrings [ "." ] [ "" ] pyVersion;
          pipxPkgs = pkgs."python${pyNoDot}Packages".pipx;
        in
        ''
          pipxPath="${pipxPkgs}/bin/pipx"
          if [ -x "$pipxPath" ]; then
            if "$pipxPath" list | grep -q "^  *package ${packageName} "; then
              echo "   Skipping ${packageName}${versionArg}: already installed"
            else
              echo "   Installing ${packageName}${versionArg} with Python ${pyVersion} pipx"
              "$pipxPath" install "${packageName}${versionArg}" || true
            fi
          else
            echo "   Error: could not find pipx at $pipxPath"
          fi
        '';

      # Generate the pipx removal script for unused packages
      generateRemoveScript = packageName:
        let
          pyVersion = pipxAttrs.${packageName}.pyVersion;
          pyNoDot = replaceStrings [ "." ] [ "" ] pyVersion;
          pipxPkgs = pkgs."python${pyNoDot}Packages".pipx;
        in
        ''
          pipxPath="${pipxPkgs}/bin/pipx"
          if [ -x "$pipxPath" ]; then
            echo "   Removing unused package ${packageName}"
            "$pipxPath" uninstall "${packageName}" || true
          fi
        '';

      # Generate the final activation script
      generateActivationScript =
        let
          definedPackages = attrNames pipxAttrs;
        in
        ''
          pipxPath="${pkgs.python310Packages.pipx}/bin/pipx"

          if [ -x "$pipxPath" ]; then
            echo ">> Listing installed pipx packages"
            installedPackages=$("$pipxPath" list --json | jq -r '.venvs | keys[]')

            # Remove unused packages
            for packageName in $installedPackages; do
              if ! echo "${toString definedPackages}" | grep -q "$packageName"; then
                echo "Removing $packageName"
                "$pipxPath" uninstall "$packageName"
              fi
            done

            # Add/update defined packages
            ${concatStringsSep "\n" (map generateInstallScript definedPackages)}
          else
            echo "Error: pipx not found at $pipxPath"
          fi
        '';
    in
    {
      # Add all pipx package paths to home.packages
      home.packages = unique (map
        (packageName:
          let
            pyVersion = pipxAttrs.${packageName}.pyVersion;
            pyNoDot = replaceStrings [ "." ] [ "" ] pyVersion;
          in
          pkgs."python${pyNoDot}Packages".pipx
        )
        (attrNames pipxAttrs)) ++ [ pkgs.jq ];

      # Activation script for pipx
      home.activation.pipx = lib.hm.dag.entryAfter [ "writeBoundary" ] generateActivationScript;
    };
}
