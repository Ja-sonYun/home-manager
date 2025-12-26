{ pkgs
, lib
, config
, agenix-secrets
, ...
}:
let
  genCodexMcpServer = server: ''
    [mcp_servers.${server.name}]
    command = "${server.command}"
    args = ${builtins.replaceStrings [ ''":"'' ] [ ''"="'' ] (builtins.toJSON server.args)}
    env = ${builtins.replaceStrings [ ''":"'' ] [ ''"="'' ] (builtins.toJSON server.env)}
    ${lib.optionalString (server ? enabled) "enabled = ${lib.boolToString server.enabled}"}
  '';

  mcpServers = [
    {
      name = "context7";
      command = pkgs.writeShellScript "context7-mcp-wrapper" ''
        ${pkgs.context7}/bin/context7-mcp \
          --api-key "$(cat ${config.age.secrets.context7-api-key.path})"
      '';
      args = [ ];
      env = { };
    }
    {
      name = "playwright";
      command = "${pkgs.playwright-mcp}/bin/mcp-server-playwright";
      args = [ ];
      env = { };
    }
    {
      name = "aws-documentation";
      command = "${pkgs.aws-documentation}/bin/awslabs.aws-documentation-mcp-server";
      args = [ ];
      env = { };
    }
    {
      name = "terraform";
      command = "${pkgs.terraform-mcp-server}/bin/terraform-mcp-server";
      args = [ "stdio" ];
      env = { };
    }
  ];

  codexMcpServersConfig = lib.concatMapStringsSep "\n" genCodexMcpServer mcpServers;

  pythonWithPackages = pkgs.python313.withPackages (ps: [
    ps.requests
    ps.numpy
  ]);

  nodeOnly = pkgs.runCommand "nodejs-24-node-only" { } ''
    mkdir -p $out/bin
    ln -s ${pkgs.nodejs_24}/bin/node $out/bin/node
  '';

  codexWrapped = pkgs.symlinkJoin {
    name = "codex-wrapped";
    paths = [ pkgs.codex ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/codex \
        --prefix PATH : ${
          lib.makeBinPath [
            nodeOnly
            pythonWithPackages
          ]
        }
    '';
  };

  notifierScript = pkgs.writeShellScript "codex-notifier-script" ''
    export PATH="$PATH:${pkgs.terminal-notifier}/bin"
    ${pkgs.python312}/bin/python3 ${toString ./notify.py} "$@"
  '';

  codexBundleSrc = "${agenix-secrets}/codex-bundle";
  codexBundleEntries = builtins.readDir codexBundleSrc;
  codexBundleKeep = lib.filterAttrs (_: t: t == "regular" || t == "directory") codexBundleEntries;

  codexBundleFiles = lib.listToAttrs (
    map
      (name: {
        name = ".codex/${name}";
        value = {
          source = codexBundleSrc + "/${name}";
        }
        // lib.optionalAttrs (codexBundleKeep.${name} == "directory") { recursive = true; };
      })
      (builtins.attrNames codexBundleKeep)
  );
in
{
  home.packages = [
    codexWrapped
  ];

  home.file = codexBundleFiles // {
    "codex-config.toml" = {
      target = ".codex/config.toml";
      force = true;
      text = ''
        model = "gpt-5.2-codex"

        approval_policy = "untrusted"
        sandbox_mode = "workspace-write"

        hide_agent_reasoning = false
        model_reasoning_effort = "high"
        model_reasoning_summary = "detailed"

        project_doc_fallback_filenames = ["CLAUDE.md"]

        notify = ["${notifierScript}"]
        file_opener = "none"

        [sandbox_workspace_write]
        network_access = true
        exclude_tmpdir_env_var = false
        exclude_slash_tmp = false
        writable_roots = []

        [tui]
        notifications = true
        animations = true

        [shell_environment_policy]
        inherit = "all"
        ignore_default_excludes = false
        exclude = ["*SECRET*", "*TOKEN*", "*KEY*", "*PASSWORD*"]
        set = {}
        include_only = []

        [features]
        web_search_request = true
        view_image_tool = true
        skills = true
        tui2 = false

        [history]
        persistence = "save-all"
        max_bytes = 10485760

        [profiles.fast]
        model_reasoning_effort = "low"

        [profiles.deep]
        model_reasoning_effort = "high"

        ${codexMcpServersConfig}
      '';
    };
  };
}
