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
      "awslabs.aws-documentation-mcp-server==1.1.2"
    ];
    exposedBinaries = [
      "awslabs.aws-documentation-mcp-server"
    ];
    outputHash = "sha256-73E/CWHFQ91aCOJf6+6YwzWeRAGhiRxUdWkp8sEj7lg=";
  };
  aws-diagram-mcp-server = pkgs.lib.pip.mkPipGlobalPackageDerivation {
    inherit pkgs;
    name = "awslabs.aws-diagram-mcp-server";
    packages = [
      "awslabs.aws-diagram-mcp-server==1.0.3"
    ];
    exposedBinaries = [
      "awslabs.aws-diagram-mcp-server"
    ];
    outputHash = "sha256-jPYsskeFd6jQ7skhPHiKl+tjpYyMPusimOMr+8Mrxr8=";
  };
  aws-pricing-mcp-server = pkgs.lib.pip.mkPipGlobalPackageDerivation {
    inherit pkgs;
    name = "awslabs.aws-pricing-mcp-server";
    packages = [
      "awslabs.aws-pricing-mcp-server==1.0.6"
    ];
    exposedBinaries = [
      "awslabs.aws-pricing-mcp-server"
    ];
    outputHash = "sha256-hxpqTXFm0v3eBWOs1Lif22RFDg0b+72/3udVCBIYVdo=";
  };
  terraform-mcp-serves = pkgs.lib.pip.mkPipGlobalPackageDerivation {
    inherit pkgs;
    name = "awslabs.terraform-mcp-serves";
    packages = [
      "awslabs.terraform-mcp-server==1.0.3"
    ];
    exposedBinaries = [
      "awslabs.terraform-mcp-server"
    ];
    outputHash = "sha256-juqRuzb+HLyIECTgw3uDAw09LbB42MA6lCbJu3XltEg=";
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
    outputHash = "sha256-60AXU6UjZkvYGtEnRUA2e+3q679gnzhDA33Ipe0Q2ng=";
  };
  serena = pkgs.lib.pip.mkPipGlobalPackageDerivation {
    inherit pkgs;
    name = "serena";
    pythonVersion = "311";
    preInstall = [
      "hatchling"
    ];
    packages = [
      "git+https://github.com/oraios/serena.git@2025-06-20#egg=serena"
    ];
    exposedBinaries = [
      "serena-mcp-server"
    ];
    outputHash = "sha256-qhQ2Ny48T1Y23EWPV6U2IZvzu1nE1Bq4KOwt0lfFJHg=";
    postInstall = ''
      ln -s ${userhome}/.serena_config.yml $out/venv/serena/lib/python3.11/serena_config.yml
      wrapProgram $out/bin/serena-mcp-server \
        --set PYTHONPATH $out/venv/serena/lib/python3.11/site-packages \
        --set PATH ${
          lib.makeBinPath [
            "${_pyright}/venv/pyright"
            pkgs.typescript-language-server
            pkgs.rust-analyzer
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
    outputHash = "sha256-y9GEft+XdyovoDOj1Xh7tn+5jRHJHMcOHpJ9qQjHk6Y=";
  };
  playwright-mcp = pkgs.lib.npm.mkNpmGlobalPackageDerivation {
    inherit pkgs;
    name = "playwright-mcp";
    packages = [
      "@playwright/mcp@0.0.31"
    ];
    exposedBinaries = [
      "mcp-server-playwright"
    ];
    outputHash = "sha256-brRx+NuK+xvx7gwpz95PuD0gZjN/pb23HcXVOwRLVtM=";
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
      "backlog.md@1.5.0"
    ];
    exposedBinaries = [
      "backlog"
    ];
    outputHash = "sha256-zgqH1fAgrNSYKiu6B7epGpIsswx+qPhZMtYgmyro31w=";
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
