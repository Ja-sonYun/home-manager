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
        "Bash(ls :*:*)"
        "Bash(cat :*:*)"
        "Base(rg :*:*)"
        "Bash(find :*:*)"
        "Bash(grep :*:*)"
        "Bash(tail :*:*)"
        "Bash(head :*:*)"
        "Bash(echo :*:*)"
      ];
      deny = [
        "Read(./.env)"
        "Read(./.env.*)"
      ];
    };
    alwaysThinkingEnabled = true;
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
      autoApprove = [ ];
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
      autoApprove = [ ];
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
      autoApprove = [ ];
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
