{ pkgs
, lib
, config
, agenix-secrets
, userhome
, ...
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
    pkgs.codex
  ];

  home.file."codex-config.toml" = {
    target = ".codex/config.toml";
    force = true;
    text = ''
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

      [features]
      web_search_request = true

      ${codexMcpServersConfig}
    '';
  };

  age.secrets.codex = {
    file = "${agenix-secrets}/encrypted/agent.age";
    path = "${userhome}/.codex/AGENTS.md";
  };
}
