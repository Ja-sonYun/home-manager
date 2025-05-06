{
  pkgs,
  cacheDir,
  ...
}:
let
  llamaindex-derivation = pkgs.stdenv.mkDerivation {
    name = "llamaindex-venv";
    unpackPhase = "true";
    buildInputs = [ pkgs.python312 ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    installPhase = ''
      python3 -m venv $out/venv
      source $out/venv/bin/activate
      pip install llama-index llama-index-vector-stores-chroma
      mkdir -p $out/bin
      ln -s $out/venv/bin/llamaindex-cli $out/bin/llamaindex-cli
      wrapProgram $out/bin/llamaindex-cli \
        --set LLAMA_INDEX_CACHE_DIR ${cacheDir}/llama_index
      deactivate
    '';
  };

  openai-codex-derivation = pkgs.stdenv.mkDerivation {
    name = "openai-codex-pkg";
    unpackPhase = "true";
    buildInputs = [ pkgs.nodejs ];
    installPhase = ''
      mkdir -p $out/bin
      export HOME=$(pwd)
      cd $out
      npm config set strict-ssl false
      npm install @openai/codex
      npm cache clean --force
      ln -s $out/node_modules/.bin/codex $out/bin/codex
    '';
  };
in
{
  home.packages = with pkgs; [
    llamaindex-derivation
    openai-codex-derivation

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
