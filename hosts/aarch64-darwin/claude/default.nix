{
  pkgs,
  config,
  userhome,
  lib,
  ...
}:
let
  claudeDesktopMcpConfig = {
    mcpServers = {
      terraform = {
        command = "docker";
        args = [
          "run"
          "-i"
          "--rm"
          "hashicorp/terraform-mcp-server"
        ];
      };
      aws-documentation-mcp-server = {
        command = "${pkgs.custom.mcp.aws-documentation}/bin/awslabs.aws-documentation-mcp-server";
        args = [ ];
        env = {
          FASTMCP_LOG_LEVEL = "ERROR";
          AWS_DOCUMENTATION_PARTITION = "aws";
        };
        disabled = false;
        autoApprove = [ ];
      };
      terraform-mcp-server = {
        command = "${pkgs.custom.mcp.terraform}/bin/awslabs.terraform-mcp-server";
        args = [ ];
        env = {
          FASTMCP_LOG_LEVEL = "ERROR";
        };
        disabled = false;
        autoApprove = [ ];
      };
      aws-diagram-mcp-server = {
        command = "${pkgs.custom.mcp.aws-diagram}/bin/awslabs.aws-diagram-mcp-server";
        args = [ ];
        env = {
          FASTMCP_LOG_LEVEL = "ERROR";
        };
        disabled = false;
        autoApprove = [ ];
      };
      aws-pricing-mcp-server = {
        command = "${pkgs.custom.mcp.aws-pricing}/bin/awslabs.aws-pricing-mcp-server";
        args = [ ];
        env = {
          FASTMCP_LOG_LEVEL = "ERROR";
        };
        disabled = false;
        autoApprove = [ ];
      };
      github = {
        command = pkgs.writeShellScript "github-mcp-wrapper" ''
          export GITHUB_PERSONAL_ACCESS_TOKEN=$(cat ${config.age.secrets.github-token.path})
          exec docker run -i --rm \
            -e GITHUB_PERSONAL_ACCESS_TOKEN \
            ghcr.io/github/github-mcp-server
        '';
      };
      sequential-thinking = {
        command = "${pkgs.custom.mcp.sequential-thinking}/bin/mcp-server-sequential-thinking";
        args = [ ];
      };
      playwright = {
        command = "${pkgs.custom.mcp.playwright}/bin/mcp-server-playwright";
        args = [ ];
      };
    };
  };
  claudeCodeSettings = {
    "$schema" = "https://json.schemastore.org/claude-code-settings.json";
    feedbackSurveyState = {
      lastShownTime = 9999999999999;
    };
    env = { };
    permissions = {
      allow = [
        "ReadFile(*)"
        "WriteFile(*)"
        "EditFile(*)"
        "Bash(grep:*)"
        "Bash(cat:*)"
        "Bash(echo:*)"
        "Bash(find:*)"
        "Bash(ls:*)"
        "Bash(mkdir:*)"
        "Bash(cp:*)"
        "Bash(mv:*)"
        "Bash(jq:*)"
        "Bash(awk:*)"
        "Bash(head:*)"
        "Bash(tree:*)"
        "Bash(touch:*)"
        "Bash(pwd:*)"
        "Bash(git status:*)"
        "Bash(git diff:*)"
        "Bash(sed:*)"
        "Bash(curl:*)"
        "Bash(gh repo list:*)"
        "Bash(gh repo view:*)"
        "Bash(gh pr list:*)"
        "Bash(gh pr view:*)"
        "Bash(gh issue list:*)"
        "Bash(gh issue view:*)"
        "Bash(gh workflow list:*)"
        "Bash(gh workflow view:*)"
        "Bash(gh run list:*)"
        "Bash(gh run view:*)"
        "Bash(gh search:*)"
        "Bash(gh release list:*)"
        "Bash(gh release view:*)"
        "Bash(gh api --method GET:*)"
        "Bash(backlog:*)"
        "Bash(serena:*)"
      ];
      deny = [ "Bash(sudo:*)" ];
    };
    model = "opus";
    statusLine = {
      type = "command";
      command = "${pkgs.custom.mcp.ccusage}/bin/ccusage statusline";
      padding = 0;
    };
    hooks = {
      Notification = [
        {
          matcher = "";
          hooks = [
            {
              type = "command";
              command = ''${pkgs.terminal-notifier}/bin/terminal-notifier -message "Waiting for permission" -title "CC" -subtitle "" -sound Glass'';
            }
          ];
        }
      ];

      Stop = [
        {
          matcher = "";
          hooks = [
            {
              type = "command";
              command = ''${pkgs.terminal-notifier}/bin/terminal-notifier -message "Stopping task" -title "CC" -subtitle "" -sound Glass'';
            }
          ];
        }
      ];
    };
  };

in
{
  home.activation = {
    serena-config = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/.serena_config.yml" ]; then
        echo "Creating default serena config file at $HOME/.serena_config.yml"
        cat > $HOME/.serena_config.yml <<-'EOF'
      gui_log_window: False
      web_dashboard: True
      log_level: 20
      trace_lsp_communication: False
      tool_timeout: 240
      projects: []
      EOF
      fi
    '';
  };
  home.file."claude_desktop_config.json" = {
    target = "Library/Application Support/Claude/claude_desktop_config.json";
    text = builtins.toJSON claudeDesktopMcpConfig;
  };
  home.file."claude_code_settings.json" = {
    target = ".claude/settings.json";
    text = builtins.toJSON claudeCodeSettings;
  };
  home.file."claude_code_slash_commands" = {
    recursive = true;
    target = ".claude/commands";
    source = toString ./commands;
  };
  home.file."claude_code_agents" = {
    recursive = true;
    target = ".claude/agents";
    source = toString ./agents;
  };
}
