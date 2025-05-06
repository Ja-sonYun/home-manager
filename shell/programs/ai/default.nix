{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    aider-chat
  ];

  home.file.aidersettings = {
    target = ".aider.model.settings.yml";
    text = ''
      - name: o4-mini
        edit_format: diff
        weak_model_name: gpt-4.1-mini
        use_repo_map: true
        examples_as_sys_msg: true
        use_temperature: false
        editor_model_name: gpt-4.1
        editor_edit_format: editor-diff
        system_prompt_prefix: 'Formatting re-enabled. '
        accepts_settings:
        - reasoning_effort
    '';
  };
  home.file.aiderconf = {
    target = ".aider.conf.yml";
    text = ''
      dark-mode: true
      auto-commits: false
      notifications: true
      yes-always: true
      model: o4-mini
      model-settings-file: ~/.aider.model.settings.yml
    '';
  };
}
