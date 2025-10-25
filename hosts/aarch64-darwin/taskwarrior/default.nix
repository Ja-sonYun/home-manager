{
  pkgs,
  # userhome,
  ...
}:
#let
#  createTaskHook = filePath: target: {
#    executable = true;
#    target = ".task/hooks/${target}";
#    text = ''
#      #!${pkgs.python312}/bin/python

#      import sys
#      sys.path.append("${userhome}/.task/hooks")

#      ${builtins.readFile filePath}
#    '';
#  };
#in
{
  # imports = [
  #   ../../../modules/zshFunc
  # ];

  home.file."taskrc" = {
    target = ".taskrc";
    source = toString ./taskrc;
  };

  # home.file."task-hooks/on-add" = createTaskHook ./hooks/on-add.py "on-add";
  # home.file."task-hooks/on-modify" = createTaskHook ./hooks/on-modify.py "on-modify";
  # home.file."task-hooks/common" = createTaskHook ./hooks/common.py "common.py";

  home.packages = with pkgs; [
    taskwarrior3
    taskwarrior-tui
  ];

  # programs.zshFunc = {
  #   task-sync = {
  #     description = "Sync taskwarrior tasks from reminder";
  #     command =
  #       let
  #         pythonEnv = pkgs.python312.withPackages (
  #           ps: with ps; [
  #             rich
  #           ]
  #         );
  #       in
  #       ''
  #         export TASKWARRIOR_BIN=${pkgs.taskwarrior3}/bin/task
  #         ${pythonEnv}/bin/python ${toString ./plugins/task-sync.py}
  #       '';
  #   };

  #   task-github-sync = {
  #     description = "Sync taskwarrior tasks from github";
  #     command =
  #       let
  #         pythonEnv = pkgs.python312.withPackages (
  #           ps: with ps; [
  #             rich
  #             pygithub
  #             openai
  #           ]
  #         );
  #       in
  #       ''
  #         export TASKWARRIOR_BIN=${pkgs.taskwarrior3}/bin/task
  #         ${pythonEnv}/bin/python ${toString ./plugins/github-todos.py}
  #       '';
  #   };
  # };
}
