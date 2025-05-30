{
  pkgs,
  userhome,
  cacheDir,
  lib,
  ...
}:
let
  _llm-functions-src-derivation = pkgs.stdenv.mkDerivation {
    name = "_llm-functions-src";
    src = ./config/llm-functions;
    installPhase = ''
      mkdir -p $out/share/llm-functions
      cp -r agents tools agents.txt tools.txt mcp.json $out/share/llm-functions/
    '';
  };

  nodeDependencies = (pkgs.callPackage ./nix/default.nix { }).nodeDependencies;

  pythonPkgs = pkgs.python3.withPackages (
    ps: with ps; [
    ]
  );

  llm-functions-derivation = pkgs.stdenv.mkDerivation {
    name = "llm-functions";

    src = pkgs.fetchFromGitHub {
      owner = "sigoden";
      repo = "llm-functions";
      rev = "e5f9a9806cacd5795a25a80dac6150af818248eb";
      sha256 = "sha256-orFuZvaddq1iTNFChgdk3B2cS8dZXmk6VOwR3f+0PUc=";
    };

    buildInputs = with pkgs; [
      bash
      jq
      argc
      _llm-functions-src-derivation
    ];

    installPhase = ''
      mkdir -p $out/share/llm-functions $out/bin
      cp -r ${_llm-functions-src-derivation}/share/llm-functions/{agents,agents.txt,tools,tools.txt,mcp.json} ./
      cp -r agents agents.txt tools tools.txt mcp.json mcp utils scripts Argcfile.sh $out/share/llm-functions/

      cat > $out/bin/llm-function <<'EOF'
      #!/usr/bin/env bash
      # always run inside the local llm-functions directory
      export PATH=${pythonPkgs}/bin:$PATH
      export PATH=${pkgs.jq}/bin:$PATH
      export NODE_PATH=${nodeDependencies}/lib/node_modules:$NODE_PATH
      cd ${userhome}/.config/llm-functions
      exec argc "$@"

      unset -e
      EOF

      chmod +x $out/bin/llm-function
    '';
  };

  aichat = pkgs.symlinkJoin {
    name = "aichat";
    paths = [ pkgs.aichat ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      wrapProgram $out/bin/aichat \
            --set AICHAT_CONFIG_DIR ${toString ./config/aichat} \
            --set AICHAT_PLATFORM openai \
            --set AICHAT_ENV_FILE ${userhome}/.env \
            --set AICHAT_SESSIONS_DIR ${cacheDir}/aichat \
            --set AICHAT_FUNCTIONS_DIR ${userhome}/.config/llm-functions
    '';
  };
in
{
  home.packages = [
    aichat
    llm-functions-derivation
  ];

  home.file.aichatconf = {
    recursive = true;
    target = ".config/aichat";
    source = toString ./config/aichat;
  };

  home.file.llm-functions = {
    recursive = true;
    target = ".config/llm-functions";
    source = "${llm-functions-derivation}/share/llm-functions";
  };

  home.activation.llm-functions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=${pythonPkgs}/bin:$PATH
    export PATH=${pkgs.jq}/bin:$PATH
    export PATH=${pkgs.argc}/bin:$PATH
    cd ${userhome}/.config/llm-functions && argc build
  '';
}
