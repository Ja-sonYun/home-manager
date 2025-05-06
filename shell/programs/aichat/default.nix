{
  pkgs,
  userhome,
  cacheDir,
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

  llm-functions = pkgs.buildNpmPackage rec {
    pname = "llm-functions";
    version = "0.1.0"; # you can set this dynamically if you want

    src = pkgs.fetchFromGitHub {
      owner = "sigoden";
      repo = "llm-functions";
      rev = "e5f9a9806cacd5795a25a80dac6150af818248eb";
      sha256 = "sha256-orFuZvaddq1iTNFChgdk3B2cS8dZXmk6VOwR3f+0PUc=";
    };

    # point npm to the bridge folder so that `npm install` happens there
    # and ensure `agents, tools, ...` are copied
    # override the default phases:
    phases = [
      "unpackPhase"
      "installPhase"
      "fixupPhase"
      "installCheckPhase"
    ];

    unpackPhase = ''
      # Copy everything from our src
      mkdir -p $sourceRoot
      cp -r ${src}/* $sourceRoot
    '';

    installPhase = ''
      # Install deps for the bridge
      cd $sourceRoot/mcp/bridge
      npm install --production
      cd $sourceRoot

      # Create final output
      mkdir -p $out/share/llm-functions
      cp -r agents agents.txt tools tools.txt mcp.json \
            $out/share/llm-functions/

      # Copy bridge node_modules
      cp -r mcp/bridge/node_modules $out/share/llm-functions/mcp/bridge/
    '';

    fixupPhase = ''
      # Remove lockfiles to slim
      rm -f $out/share/llm-functions/mcp.json
      rm -f $out/share/llm-functions/mcp/bridge/package-lock.json
      rm -rf $out/share/llm-functions/mcp/bridge/node_modules/.package-lock.json
    '';

    # No tests by default
    installCheckPhase = ''
      # optional smoke test
    '';

    # Ensure Node.js is in PATH
    buildInputs = [ pkgs.nodejs_20 ];
  };

  #llm-functions-derivation = pkgs.stdenv.mkDerivation {
  #  name = "llm-functions";

  #  src = pkgs.fetchFromGitHub {
  #    owner = "sigoden";
  #    repo = "llm-functions";
  #    rev = "e5f9a9806cacd5795a25a80dac6150af818248eb";
  #    sha256 = "sha256-orFuZvaddq1iTNFChgdk3B2cS8dZXmk6VOwR3f+0PUc=";
  #  };

  #  buildInputs = with pkgs; [
  #    bash
  #    jq
  #    argc
  #    nodejs_20
  #    python312
  #    _llm-functions-src-derivation
  #  ];

  #  installPhase = ''
  #    mkdir -p $out/share/llm-functions $out/bin
  #    cp -r ${_llm-functions-src-derivation}/share/llm-functions/{agents,agents.txt,tools,tools.txt,mcp.json} ./
  #    cp -r agents agents.txt tools tools.txt mcp.json mcp utils scripts Argcfile.sh $out/share/llm-functions/

  #    export HOME=$(pwd)
  #    npm config set strict-ssl false
  #    (cd $out/share/llm-functions/mcp/bridge && npm install)
  #    npm cache clean --force

  #    rm -f $out/share/llm-functions/mcp/bridge/package-lock.json
  #    rm -f $out/share/llm-functions/mcp/bridge/node_modules/.package-lock.json

  #    rm -f $out/share/llm-functions/mcp.json

  #    cat > $out/bin/llm-function <<'EOF'
  #    #!/usr/bin/env bash
  #    # always run inside the local llm-functions directory
  #    export PATH=${pkgs.nodejs_20}/bin:$PATH
  #    export PATH=${pkgs.python312}/bin:$PATH
  #    export PATH=${pkgs.jq}/bin:$PATH
  #    export NODE_PATH=${userhome}/.config/llm-functions/mcp/bridge/node_modules
  #    cd ${userhome}/.config/llm-functions
  #    if [ ! -f functions.json ]; then
  #      argc build
  #    fi
  #    exec argc "$@"
  #    EOF

  #    chmod +x $out/bin/llm-function
  #  '';
  #};

  aichat = pkgs.aichat.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
    postInstall =
      (old.postInstall or "")
      + ''
        wrapProgram $out/bin/aichat \
          --set AICHAT_CONFIG_DIR ${toString ./config/aichat} \
          --set AICHAT_PLATFORM openai \
          --set AICHAT_ENV_FILE ${userhome}/.env \
          --set AICHAT_SESSIONS_DIR ${cacheDir}/aichat \
          --set AICHAT_FUNCTIONS_DIR ${userhome}/.config/llm-functions
      '';
  });
in
{
  home.packages = [
    aichat
    llm-functions
  ];

  home.file.aichatconf = {
    recursive = true;
    target = ".config/aichat";
    source = toString ./config/aichat;
  };

  home.file.llm-functions = {
    recursive = true;
    target = ".config/llm-functions";
    source = "${llm-functions}/share/llm-functions";
  };
}
