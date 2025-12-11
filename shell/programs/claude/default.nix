{
  pkgs,
  lib,
  config,
  agenix-secrets,
  userhome,
  ...
}:
let
  settings = {
    permissions = {
      allow = [
        "WebSearch"
        "WebFetch(domain:*)"
        "Read(**)"
        "Bash(git status:*)"
        "Bash(git diff:*)"
        "Bash(git log:*)"
        "Bash(git show:*)"
        "Bash(ls :*)"
        "Bash(cat :*)"
        "Bash(rg:*)"
        "Bash(find :*)"
        "Bash(grep :*)"
        "Bash(tail :*)"
        "Bash(head :*)"
        "Bash(echo :*)"
        "Bash(jq :*)"
        "Bash(yq :*)"
        "Bash(make:*)"
        "Bash(nix build:*)"
        "Bash(nix log:*)"
        "Bash(nix flake lock:*)"
      ];
      deny = [
        "Read(./.env)"
        "Read(./.env.*)"
      ];
    };
    alwaysThinkingEnabled = true;
    hooks = {
      Notification = [
        {
          matcher = "permission_prompt";
          hooks = [
            {
              type = "command";
              command = "${pkgs.terminal-notifier}/bin/terminal-notifier -title 'cc'p -message 'Awaiting your input' -sound default";
            }
          ];
        }
        {
          matcher = "idle_prompt";
          hooks = [
            {
              type = "command";
              command = "${pkgs.terminal-notifier}/bin/terminal-notifier -title 'cci' -message 'Awaiting your input' -sound default";
            }
          ];
        }
      ];
    };
  };
  mcpServers = {
    github = {
      command = pkgs.writeShellScript "github-mcp-wrapper" ''
        export GITHUB_PERSONAL_ACCESS_TOKEN=$(cat ${config.age.secrets.github-token.path})
        exec docker run -i --rm \
          -e GITHUB_PERSONAL_ACCESS_TOKEN \
          ghcr.io/github/github-mcp-server
      '';
      args = [ ];
      env = { };
      transportType = "stdio";
      autoApprove = [
        "get_file_contents"
        "search_repositories"
        "search_code"
      ];
      disabled = false;
    };
    context7 = {
      command = pkgs.writeShellScript "context7-mcp-wrapper" ''
        ${pkgs.context7}/bin/context7-mcp \
          --api-key "$(cat ${config.age.secrets.context7-api-key.path})"
      '';
      args = [ ];
      env = { };
      transportType = "stdio";
      autoApprove = [
        "resolve-library-id"
        "get-library-docs"
      ];
      disabled = false;
    };
    playwright = {
      command = "${pkgs.playwright-mcp}/bin/mcp-server-playwright";
      args = [ ];
      env = { };
      transportType = "stdio";
      autoApprove = [ ];
      disabled = false;
    };
    aws-documentation = {
      command = "${pkgs.aws-documentation}/bin/awslabs.aws-documentation-mcp-server";
      args = [ ];
      env = { };
      transportType = "stdio";
      autoApprove = [
        "read_documentation"
        "search_documentation"
        "recommend"
      ];
      disabled = false;
    };
  };
in
{
  home.packages = [
    pkgs.claude-code
  ];

  home.file."claude/settings.json" = {
    target = ".claude/settings.json";
    force = true;
    text = builtins.toJSON settings;
  };
  home.file."Library/Application Support/Claude/claude_desktop_config.json" = {
    target = "Library/Application Support/Claude/claude_desktop_config.json";
    force = true;
    text = builtins.toJSON {
      inherit mcpServers;
    };
  };
  home.activation.inject-claude-code-mcp = lib.hm.dag.entryAfter [ "installPackages" ] ''
    ${pkgs.jq}/bin/jq                                                      \
      -n                                                                   \
      --slurpfile                                                          \
      new ~/Library/Application\ Support/Claude/claude_desktop_config.json \
        '(try input catch {}) | .mcpServers = $new[0].mcpServers'          \
        ~/.claude.json > temp.json                                         \
      && mv temp.json ~/.claude.json
  '';

  age.secrets.claude = {
    file = "${agenix-secrets}/agent.age";
    path = "${userhome}/.claude/CLAUDE.md";
  };
}
