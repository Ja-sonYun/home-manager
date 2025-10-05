{
  pkgs,
  lib,
  config,
  agenix-secrets,
  userhome,
  ...
}:
let
  genCodexMcpServer = server: ''
    [mcp_servers.${server.name}]
    command = "${server.command}"
    args = ${builtins.replaceStrings [ ''":"'' ] [ ''"="'' ] (builtins.toJSON server.args)}
    env = ${builtins.replaceStrings [ ''":"'' ] [ ''"="'' ] (builtins.toJSON server.env)}
  '';

  mcpServers = [
    {
      name = "terraform";
      command = "docker";
      args = [
        "run"
        "-i"
        "--rm"
        "hashicorp/terraform-mcp-server"
      ];
      env = { };
    }
    {
      name = "aws-documentation";
      command = "${pkgs.custom.mcp.aws-documentation}/bin/awslabs.aws-documentation-mcp-server";
      args = [ ];
      env = {
        FASTMCP_LOG_LEVEL = "ERROR";
        AWS_DOCUMENTATION_PARTITION = "aws";
      };
    }
    {
      name = "terraform-local";
      command = "${pkgs.custom.mcp.terraform}/bin/awslabs.terraform-mcp-server";
      args = [ ];
      env = {
        FASTMCP_LOG_LEVEL = "ERROR";
      };
    }
    {
      name = "aws-diagram";
      command = "${pkgs.custom.mcp.aws-diagram}/bin/awslabs.aws-diagram-mcp-server";
      args = [ ];
      env = {
        FASTMCP_LOG_LEVEL = "ERROR";
      };
    }
    {
      name = "aws-pricing";
      command = "${pkgs.custom.mcp.aws-pricing}/bin/awslabs.aws-pricing-mcp-server";
      args = [ ];
      env = {
        FASTMCP_LOG_LEVEL = "ERROR";
      };
    }
    {
      name = "github";
      command = pkgs.writeShellScript "github-mcp-wrapper" ''
        export GITHUB_PERSONAL_ACCESS_TOKEN=$(cat ${config.age.secrets.github-token.path})
        exec docker run -i --rm \
          -e GITHUB_PERSONAL_ACCESS_TOKEN \
          ghcr.io/github/github-mcp-server
      '';
      args = [ ];
      env = { };
    }
    {
      name = "slack";
      command = pkgs.writeShellScript "slack-mcp-wrapper" ''
        SLACK_TOKEN=$(cat ${config.age.secrets.slack.path})
        export SLACK_MCP_XOXC_TOKEN=$(echo $SLACK_TOKEN | awk -F: '{print $1}')
        export SLACK_MCP_XOXD_TOKEN=$(echo $SLACK_TOKEN | awk -F: '{print $2}')
        exec docker run -i --rm \
          -e SLACK_MCP_XOXC_TOKEN \
          -e SLACK_MCP_XOXD_TOKEN \
          ghcr.io/korotovsky/slack-mcp-server mcp-server --transport stdio
      '';
      args = [ ];
      env = { };
    }
    {
      name = "sequential-thinking";
      command = "${pkgs.custom.mcp.sequential-thinking}/bin/mcp-server-sequential-thinking";
      args = [ ];
      env = { };
    }
    {
      name = "context7";
      command = pkgs.writeShellScript "context7-mcp-wrapper" ''
        export CONTEXT7_API_KEY=$(cat ${config.age.secrets.context7-api-key.path})
        exec ${pkgs.custom.mcp.context7}/bin/context7-mcp --api-key "$CONTEXT7_API_KEY"
      '';
      args = [ ];
      env = { };
    }
    # {
    #   name = "browser-use";
    #   command = "${pkgs.custom.mcp.browser-use}/bin/browser-use";
    #   args = [ "--mcp" ];
    #   env = { };
    # }
    # {
    #   name = "playwright";
    #   command = "${pkgs.custom.mcp.playwright}/bin/mcp-server-playwright";
    #   args = [ ];
    #   env = { };
    # }
    # {
    #   name = "serena";
    #   command = "${pkgs.custom.mcp.serena}/bin/serena-mcp-server";
    #   args = [
    #     "--context"
    #     "codex"
    #   ];
    #   env = { };
    # }
  ];

  codexMcpServersConfig = lib.concatMapStringsSep "\n" genCodexMcpServer mcpServers;

  notifierScript = pkgs.writeShellScript "codex-notifier-script" ''
    export PATH="$PATH:${pkgs.terminal-notifier}/bin"
    ${toString ./check-codex-window}
    ${pkgs.python312}/bin/python3 ${toString ./notify.py} "$@"
  '';
in
{
  home.packages = [
    pkgs.ollama
    pkgs.custom.ai.codex
    # pkgs.custom.mcp.serena
  ];

  home.file."codex-config.toml" = {
    target = ".codex/config.toml";
    text = ''
      model = "gpt-5-codex"

      approval_policy = "untrusted"
      sandbox_mode = "workspace-write"

      hide_agent_reasoning = false
      model_reasoning_effort = "medium"

      notify = ["${notifierScript}"]
      file_opener = "none"

      [sandbox_workspace_write]
      network_access = true
      exclude_tmpdir_env_var = false
      exclude_slash_tmp = false
      writable_roots = []

      [tui]
      notifications = true

      [shell_environment_policy]
      inherit = "all"
      ignore_default_excludes = false
      exclude = []
      set = {}
      include_only = []

      [tools]
      web_search = true

      ${codexMcpServersConfig}
    '';
  };

  home.activation = {
    # serena-config = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #   if [ ! -f "$HOME/.serena_config.yml" ]; then
    #     echo "Creating default serena config file at $HOME/.serena_config.yml"
    #     cat > $HOME/.serena_config.yml <<-'EOF'
    #   gui_log_window: False
    #   web_dashboard: True
    #   log_level: 20
    #   trace_lsp_communication: False
    #   tool_timeout: 240
    #   projects: []
    #   EOF
    #   fi
    # '';
  };

  # age.secrets.claude = {
  #   file = "${agenix-secrets}/agent.age";
  #   path = "${userhome}/.claude/CLAUDE.md";
  # };
  age.secrets.codex = {
    file = "${agenix-secrets}/agent.age";
    path = "${userhome}/.codex/AGENTS.md";
  };
}
