{
  pkgs,
  config,
  userhome,
  lib,
  ...
}:
let
  aws-documentation-mcp-server = pkgs.lib.pip.mkPipGlobalPackageDerivation {
    inherit pkgs;
    name = "awslabs.aws-documentation-mcp-server";
    packages = [
      "awslabs.aws-documentation-mcp-server==1.1.3"
    ];
    exposedBinaries = [
      "awslabs.aws-documentation-mcp-server"
    ];
    outputHash = "sha256-lEb1SK5FUS4JIY5zJhBnpnX//0zftcUQBGvznb4m+H0=";
  };
  aws-diagram-mcp-server = pkgs.lib.pip.mkPipGlobalPackageDerivation {
    inherit pkgs;
    name = "awslabs.aws-diagram-mcp-server";
    packages = [
      "awslabs.aws-diagram-mcp-server==1.0.6"
    ];
    exposedBinaries = [
      "awslabs.aws-diagram-mcp-server"
    ];
    outputHash = "sha256-j2ijeGvtPCuyb5lLT5qo+5LihSxlUGcoErEY4uSTxcQ=";
  };
  aws-pricing-mcp-server = pkgs.lib.pip.mkPipGlobalPackageDerivation {
    inherit pkgs;
    name = "awslabs.aws-pricing-mcp-server";
    packages = [
      "awslabs.aws-pricing-mcp-server==1.0.10"
    ];
    exposedBinaries = [
      "awslabs.aws-pricing-mcp-server"
    ];
    outputHash = "sha256-FYjNMzGLTekO5/o226bzzGIH+5vGrN8Pue6aJqTZTCw=";
  };
  terraform-mcp-serves = pkgs.lib.pip.mkPipGlobalPackageDerivation {
    inherit pkgs;
    name = "awslabs.terraform-mcp-serves";
    packages = [
      "awslabs.terraform-mcp-server==1.0.4"
    ];
    exposedBinaries = [
      "awslabs.terraform-mcp-server"
    ];
    outputHash = "sha256-oW449aF1Qx4UalrDeTxCWZiS9yPtLrWf/dvan0zUxzY=";
  };
  _pyright = pkgs.lib.pip.mkPipGlobalPackageDerivation {
    inherit pkgs;
    name = "pyright";
    pythonVersion = "311";
    packages = [
      "pyright==1.1.403"
    ];
    exposedBinaries = [
      "pyright"
    ];
    outputHash = "sha256-iCy6bLhM7YJxKzDzqWt8XWj9vUwbsZzBTIohUD6FOWs=";
  };
  serena = pkgs.lib.pip.mkPipGlobalPackageDerivation {
    inherit pkgs;
    name = "serena";
    pythonVersion = "311";
    preInstall = [
      "hatchling"
    ];
    packages = [
      "git+https://github.com/oraios/serena.git@v0.1.3#egg=serena-agent"
    ];
    exposedBinaries = [
      "serena-mcp-server"
    ];
    outputHash = "sha256-Gl3MLoE4Qu2+1iwxYhcX6Sq+r/aTQoSC9I/cdES0WNg=";
    postInstall = ''
      ln -s ${userhome}/.serena_config.yml $out/venv/serena/lib/python3.11/serena_config.yml
      wrapProgram $out/bin/serena-mcp-server \
        --set PYTHONPATH $out/venv/serena/lib/python3.11/site-packages \
        --set PATH ${
          lib.makeBinPath [
            "${_pyright}/venv/pyright"
            pkgs.typescript-language-server
            # pkgs.rust-analyzer # Temporarily disabled due to hash mismatch
          ]
        }
    '';
  };
  sequential-thinking = pkgs.lib.npm.mkNpmGlobalPackageDerivation {
    inherit pkgs;
    name = "sequential-thinking-mcp-server";
    packages = [
      "@modelcontextprotocol/server-sequential-thinking@2025.7.1"
    ];
    exposedBinaries = [
      "mcp-server-sequential-thinking"
    ];
    outputHash = "sha256-LHMN/M/MTiNNoJsVeqFNQVGzlPUvXUWtdtNwdXb0Ll8=";
  };
  playwright-mcp = pkgs.lib.npm.mkNpmGlobalPackageDerivation {
    inherit pkgs;
    name = "playwright-mcp";
    packages = [
      "@playwright/mcp@0.0.33"
    ];
    exposedBinaries = [
      "mcp-server-playwright"
    ];
    outputHash = "sha256-d+2UYMECRuIh35P/+qD7r3txRZv5+DklwmdYdrf/zUk=";
    postInstall = ''
      binary_path=$(readlink -f $out/bin/mcp-server-playwright)
      rm -f $out/bin/mcp-server-playwright
      cat > $out/bin/mcp-server-playwright <<EOF
      #!${pkgs.runtimeShell}
      export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
      export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
      exec $binary_path "\$@"
      EOF
      chmod +x $out/bin/mcp-server-playwright
    '';
  };
  backlog-md = pkgs.lib.npm.mkNpmGlobalPackageDerivation {
    inherit pkgs;
    name = "backlog-md";
    packages = [
      "backlog.md@1.8.2"
    ];
    exposedBinaries = [
      "backlog"
    ];
    outputHash = "sha256-EIpLDPyLikNpUpzLdea8FYci7/5zTq2YEN9EF+1Q/KQ=";
  };
  ccusage = pkgs.lib.npm.mkNpmGlobalPackageDerivation {
    inherit pkgs;
    name = "ccusage";
    packages = [
      "ccusage@15.9.4"
    ];
    exposedBinaries = [
      "ccusage"
    ];
    outputHash = "sha256-yCNVCgNjWXlgfGieQMBQucfvh22Deksc9dzreMCRMzU=";
  };
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
        command = "${aws-documentation-mcp-server}/bin/awslabs.aws-documentation-mcp-server";
        args = [ ];
        env = {
          FASTMCP_LOG_LEVEL = "ERROR";
          AWS_DOCUMENTATION_PARTITION = "aws";
        };
        disabled = false;
        autoApprove = [ ];
      };
      terraform-mcp-server = {
        command = "${terraform-mcp-serves}/bin/awslabs.terraform-mcp-server";
        args = [ ];
        env = {
          FASTMCP_LOG_LEVEL = "ERROR";
        };
        disabled = false;
        autoApprove = [ ];
      };
      aws-diagram-mcp-server = {
        command = "${aws-diagram-mcp-server}/bin/awslabs.aws-diagram-mcp-server";
        args = [ ];
        env = {
          FASTMCP_LOG_LEVEL = "ERROR";
        };
        disabled = false;
        autoApprove = [ ];
      };
      aws-pricing-mcp-server = {
        command = "${aws-pricing-mcp-server}/bin/awslabs.aws-pricing-mcp-server";
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
        command = "${sequential-thinking}/bin/mcp-server-sequential-thinking";
        args = [ ];
      };
      playwright = {
        command = "${playwright-mcp}/bin/mcp-server-playwright";
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
      command = "${ccusage}/bin/ccusage statusline";
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
  home.packages = [
    serena
    backlog-md
    ccusage
  ];
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
