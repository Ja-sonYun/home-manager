{ config, pkgs, lib, ... }:

with lib;

let
  cargoAttrs = config.programs.cargo;
in
{
  ##############################
  # Module Options Definition
  ##############################
  options.programs.cargo = mkOption {
    type = types.attrs;
    default = { };
    description = ''
      Configuration for cargo-managed Rust CLI tools.
      Each attribute is a tool name with a definition containing:
      - version: Version to install (null for latest from crates.io).
      # TODO:
      - ldpkgs: List of Nix packages to link before installing the tool.
    '';
  };

  ##########################################
  # Configuration: Activate if tools exist
  ##########################################
  config =
    let
      # Generate the cargo activation script for adding/updating tools
      generateInstallScript = toolName:
        let
          toolConf = cargoAttrs.${toolName};
          versionArg = if toolConf.version == null then "" else "--version ${toolConf.version}";
          cargoPath = "${pkgs.cargo}/bin/cargo";
        in
        ''
          if [ -x "$cargoPath" ]; then
            if "$cargoPath" install --list | grep -q "^${toolName} "; then
              echo "   Skipping ${toolName}${versionArg}: already installed"
            else
              echo "   Installing ${toolName}${versionArg} using cargo"
              "$cargoPath" install "${toolName}" ${versionArg} || true
            fi
          else
            echo "   Error: cargo not found at $cargoPath"
          fi
        '';

      # Generate the cargo removal script for unused tools
      generateRemoveScript = toolName:
        let
          cargoPath = "${pkgs.cargo}/bin/cargo";
        in
        ''
          if [ -x "$cargoPath" ]; then
            echo "   Removing unused tool ${toolName}"
            "$cargoPath" uninstall "${toolName}" || true
          fi
        '';

      # Generate the final activation script
      generateActivationScript =
        let
          definedTools = attrNames cargoAttrs;
        in
        ''
          export PATH="$PATH:${pkgs.clang}/bin"
          export LIBRARY_PATH="${pkgs.libiconv}/lib"
          cargoPath="${pkgs.cargo}/bin/cargo"
          awkPath="${pkgs.gawk}/bin/awk"

          if [ -x "$cargoPath" ]; then
            echo ">> Listing installed cargo tools"
            installedTools=$("$cargoPath" install --list | $awkPath '/^[a-zA-Z0-9_-]+ / {print $1}')

            # Remove unused tools
            for toolName in $installedTools; do
              if ! echo "${toString definedTools}" | grep -q "$toolName"; then
                echo "Removing $toolName"
                "$cargoPath" uninstall "$toolName"
              fi
            done

            # Add/update defined tools
            ${concatStringsSep "\n" (map generateInstallScript definedTools)}
          else
            echo "Error: cargo not found at $cargoPath"
          fi
        '';
    in
    {
      # Add Rust stable to home.packages
      home.packages = [
        pkgs.cargo
        pkgs.gawk
        pkgs.clang
        pkgs.libiconv
      ];
      home.sessionPath = [
        "$HOME/.cargo/bin"
      ];
      # Activation script for cargo
      home.activation.cargo = lib.hm.dag.entryAfter [ "writeBoundary" ] generateActivationScript;
    };
}
