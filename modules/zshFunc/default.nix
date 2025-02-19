{ config, pkgs, lib, ... }:

with lib;

let
  zshFuncAttrs = config.programs.zshFunc;
in
{
  ##############################
  # Module Options Definition
  ##############################
  options.programs.zshFunc = mkOption {
    type = types.attrs;
    default = { };
    description = ''
      Configuration for zsh functions.
      Each attribute is a function name with a definition containing:
      - description: A brief description of what the function does.
      - command: The shell command to execute.
    '';
  };

  ##########################################
  # Configuration: Generate `.zshfuncs` File
  ##########################################
  config =
    let
      # Generate the content of a single function
      generateZshFunction = functionName: functionConfig:
        let
          funcDescription = functionConfig.description or "No description provided.";
          funcCommand = functionConfig.command or "echo 'No command provided.'";
          scripts = ''
            #!${pkgs.zsh}/bin/zsh

            if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
              echo "${funcDescription}"
              return 1
            fi
            ${funcCommand}
          '';
        in
        (pkgs.writeScriptBin functionName scripts);

      allFunctions = mapAttrsToList generateZshFunction zshFuncAttrs;
    in
    {
      home.packages = allFunctions;
    };
}
