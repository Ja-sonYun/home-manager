{
  pkgs,
  userhome,
  lib,
  ...
}:
let
  aws-documentation-mcp-server = pkgs.lib.pip.mkPipGlobalPackageDerivation {
    inherit pkgs;
    name = "awslabs.aws-documentation-mcp-server";
    packages = [
      "awslabs.aws-documentation-mcp-server==1.1.0"
    ];
    exposedBinaries = [
      "awslabs.aws-documentation-mcp-server"
    ];
    outputHash = "sha256-r+UNEdbaBjVivzphqojXaCQOoeaXOmrKPYLD8XlbqFE=";
  };
  aws-diagram-mcp-server = pkgs.lib.pip.mkPipGlobalPackageDerivation {
    inherit pkgs;
    name = "awslabs.aws-diagram-mcp-server";
    packages = [
      "awslabs.aws-diagram-mcp-server==1.0.1"
    ];
    exposedBinaries = [
      "awslabs.aws-diagram-mcp-server"
    ];
    outputHash = "sha256-/tiyf/PkgVmhzfijzs6kJPKQ2nU41nFpVv7a4qON+RA=";
  };
  terraform-mcp-serves = pkgs.lib.pip.mkPipGlobalPackageDerivation {
    inherit pkgs;
    name = "awslabs.terraform-mcp-serves";
    packages = [
      "awslabs.terraform-mcp-server==1.0.1"
    ];
    exposedBinaries = [
      "awslabs.terraform-mcp-server"
    ];
    outputHash = "sha256-46SHjaK4vJLoSK4V14V8/0liCU2kbu7mVaetvDgF5qk=";
  };
  _pyright = pkgs.lib.pip.mkPipGlobalPackageDerivation {
    inherit pkgs;
    name = "pyright";
    pythonVersion = "312";
    packages = [
      "pyright==1.1.402"
    ];
    exposedBinaries = [
      "pyright"
    ];
    outputHash = "sha256-zbaiTeyYmg2heHsfPeoF7/JhVVbcR4kTKVTVHj/4iH0=";
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
    outputHash = "sha256-arukbGobYeBuJTMIB1gkTdbUORXzNuk0WTb5ew07+/A=";
    postInstall = ''
      ln -s ${userhome}/.serena_config.yml $out/venv/serena/lib/python3.11/serena_config.yml
      wrapProgram $out/bin/serena-mcp-server \
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
      "@modelcontextprotocol/server-sequential-thinking@0.6.2"
    ];
    exposedBinaries = [
      "mcp-server-sequential-thinking"
    ];
    outputHash = "sha256-GpxbglAEQec32CTRzBAe0TlVhgqGm+uDvF9kVOcrDuQ=";
  };
  playwright-mcp = pkgs.lib.npm.mkNpmGlobalPackageDerivation {
    inherit pkgs;
    name = "playwright-mcp";
    packages = [
      "@playwright/mcp@0.0.29"
    ];
    exposedBinaries = [
      "mcp-server-playwright"
    ];
    outputHash = "sha256-anmdoDiFyI0M72Zg6jZFlKCmYxlmmlkVrBSosEPS1KY=";
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
      "backlog.md@1.0.1"
    ];
    exposedBinaries = [
      "backlog"
    ];
    outputHash = "sha256-Dgo7OzSw6B5vHjJ5+085qum7kNfZu9CI6XiBkVb+iLc=";
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
    text = ''
      {
        "mcpServers": {
          "terraform": {
            "command": "sh",
            "args": [
              "-c",
              "docker rm -f terraform-hashicorp-mcp 2>/dev/null; docker run -i --rm --name terraform-hashicorp-mcp hashicorp/terraform-mcp-server"
            ]
          },
          "awslabs.aws-documentation-mcp-server": {
            "command": "${aws-documentation-mcp-server}/bin/awslabs.aws-documentation-mcp-server",
            "args": [],
            "env": {
              "FASTMCP_LOG_LEVEL": "ERROR",
              "AWS_DOCUMENTATION_PARTITION": "aws"
            },
            "disabled": false,
            "autoApprove": []
          },
          "awslabs.terraform-mcp-server": {
            "command": "${terraform-mcp-serves}/bin/awslabs.terraform-mcp-server",
            "args": [],
            "env": {
              "FASTMCP_LOG_LEVEL": "ERROR"
            },
            "disabled": false,
            "autoApprove": []
          },
          "awslabs.aws-diagram-mcp-server": {
            "command": "${aws-diagram-mcp-server}/bin/awslabs.aws-diagram-mcp-server",
            "args": [],
            "env": {
              "FASTMCP_LOG_LEVEL": "ERROR"
            },
            "disabled": false,
            "autoApprove": []
          },
          "sequential-thinking": {
            "command": "${sequential-thinking}/bin/mcp-server-sequential-thinking",
            "args": []
          },
          "playwright": {
            "command": "${playwright-mcp}/bin/mcp-server-playwright",
            "args": []
          }
        }
      }
    '';
  };
}
