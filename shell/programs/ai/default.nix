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
    installPhase = ''
      python3 -m venv $out/venv
      source $out/venv/bin/activate
      pip install llama-index llama-index-vector-stores-chroma
      mkdir -p $out/bin
      ln -s $out/venv/bin/llamaindex-cli $out/bin/llamaindex-cli
      deactivate
    '';
  };
in
{
  home.packages = with pkgs; [
    llamaindex-derivation
  ];

  home.sessionVariables.LLAMA_INDEX_CACHE_DIR = "${cacheDir}/llama_index";
}
