{ pkgs
, lib
, config
, userhome
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

  notifierScript = pkgs.writeShellScript "codex-notifier-script" ''
    export PATH="$PATH:${pkgs.terminal-notifier}/bin"
    ${pkgs.python312}/bin/python3 ${toString ./notify.py} "$@"
  '';

  extractScriptPath = "${config.home.homeDirectory}/.codex/nix/extract-bundle";
in
lib.mkMerge [
  {
    home.packages = [
      pkgs.codex
    ];

    home.file."codex-config.toml" = {
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
        tui2 = true

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

    home.file.".codex/nix/extract-bundle" = {
      executable = true;
      text = ''
        #!/bin/sh
        [ -f "${config.age.secrets.codex-bundle.path}" ] || exit 0
        ${pkgs.python3}/bin/python3 ${../claude/extract-claude-bundle.py} \
          "${config.age.secrets.codex-bundle.path}" \
          "${userhome}/.codex"
      '';
    };
  }

  (lib.mkIf pkgs.stdenv.isDarwin {
    launchd.agents.extract-codex-bundle = {
      enable = true;
      config = {
        Label = "org.nix-community.home.extract-codex-bundle";
        WatchPaths = [ config.age.secrets.codex-bundle.path ];
        ProgramArguments = [ extractScriptPath ];
        RunAtLoad = true;
      };
    };
  })

  (lib.mkIf pkgs.stdenv.isLinux {
    systemd.user.paths.extract-codex-bundle = {
      Unit.Description = "Watch codex bundle secret";
      Path.PathChanged = config.age.secrets.codex-bundle.path;
      Install.WantedBy = [ "paths.target" ];
    };
    systemd.user.services.extract-codex-bundle = {
      Unit.Description = "Extract codex bundle";
      Service = {
        Type = "oneshot";
        ExecStart = extractScriptPath;
      };
    };
  })
]
