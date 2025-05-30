{
  pkgs,
  libs,
  system,
  ...
}:
let
  codex = libs.npm.mkNpmGlobalPackageDerivation {
    inherit pkgs system;
    name = "openai-codex";
    packages = [
      "@openai/codex@0.1.2505172129"
    ];
    exposedBinaries = [
      "codex"
    ];
    outputHash = "sha256-uMitqAbIxE2Ypp3KRcgUtvMgkSuT630uTTcndFz8ONM=";
  };
  llama-index = libs.pip.mkPipGlobalPackageDerivation {
    inherit pkgs system;
    name = "llama-index";
    packages = [
      "llama-index==0.12.36"
      "llama-index-vector-stores-chroma"
      "setuptools>=40.8.0"
    ];
    exposedBinaries = [
      "llamaindex-cli"
    ];
    outputHash = "sha256-Fe3nf5pW3NReCnFOHYlGL29hCOqmOWIJEXX9jjXKRgg=";
  };
  llm = libs.pip.mkPipGlobalPackageDerivation {
    inherit pkgs system;
    name = "llm";
    packages = [
      "llm==0.26"
      "llm-mlx==0.4"
    ];
    exposedBinaries = [
      "llm"
    ];
    outputHash = "sha256-6nwJ3UwuU+VrhTlBLE/lCwNTBMAUo+NUv/44iQzZU7I=";
  };
in
{
  home.packages = with pkgs; [
    aider-chat
    codex
    llama-index
    llm
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
