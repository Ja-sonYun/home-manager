{
  pkgs,
  system,
  ...
}:
{
  imports = [
    ../../../modules/zshFunc
  ];
  home.packages = with pkgs; [
    tmux
    pstree
    custom.tmux.tmux-menu
  ];
  home.file.tmuxconf = {
    target = ".tmux.conf";
    source = toString ./tmux.conf;
  };
  home.sessionVariables.TMUX_CONFIG = toString ./config;

  home.shellAliases = {
    tm = toString ./config/scripts/tmux;
  };

  programs.zshFunc = {
    _gen-close-hook = {
      description = "Generate a tmux close hook for a given command";
      command = ''
        command="$1"
        mkdir -p .hooks/on_leave .hooks/on_exit
        cat <<EOF >".hooks/on_exit/close_''${command}"
        if [[ ! -z "\$TMUX" ]]; then
           local hooks_dir=\$(find_hooks_dir "\$OLDPWD")
           if [[ -n "\$hooks_dir" ]]; then
               local project_root=\$(dirname "\$hooks_dir")
               tmux_session_name=\$(tmux list-sessions | awk -F: '/'"git_root_''${command}_\$(echo \$project_root | tr '/' '_' | tr ' ' '_'):"'/ {print \$1}')
               if [[ -n "\$tmux_session_name" ]]; then
                   if ask_yes_no "Kill ''${command}"; then
                       tmux kill-session -t \$tmux_session_name 2>/dev/null && \\
                           echo "Closed tmux session for ''${command}_\$(echo \$project_root | tr '/' '_' | tr ' ' '_')" || \\
                           echo "Failed to close tmux session for ''${command}_\$(echo \$project_root | tr '/' '_' | tr ' ' '_')"
                   else
                       echo "Cancelled."
                   fi
               fi
           fi
        fi
        EOF
        cp ".hooks/on_exit/close_''${command}" ".hooks/on_leave/close_''${command}"
      '';
    };
  };
}
