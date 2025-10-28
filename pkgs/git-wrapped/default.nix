{ pkgs, ... }:
let
  scriptTemplate = builtins.readFile ./git-wrapped;
  gitRestoreScript = builtins.replaceStrings [ "%%GIT%%" ] [ "${pkgs.git}" ] scriptTemplate;
in
pkgs.writeShellScriptBin "git" ''
  ${gitRestoreScript}
''
