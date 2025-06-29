{
  pkgs,
  cacheDir,
  configDir,
  ...
}:
{
  imports = [
    ../../modules/zshFunc

    ./zle/better_grammar
  ];

  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
      ];
    };

    zplug = {
      enable = true;

      zplugHome = "${cacheDir}/zplug";
      plugins = [
        { name = "jeffreytse/zsh-vi-mode"; }
      ];
    };

    shellAliases = {
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
      dud = "du -h -d 1 ";
    };

    shellGlobalAliases = {
      G = "| grep";
      L = "| less";
      T = "| tail";
      H = "| head";
      S = "| sort";
      D = "| base64 -d";
      __ = "| ${pkgs.spacer}/bin/spacer";
    };

    localVariables = { };

    initContent =
      let
        PS1 =
          let
            promptTime = "[%D{%d/%m,%H:%M:%S}]";
            jobStatus = "%{$fg[red]%}%(1j.%U•%j%u|.)%{$reset_color%}";
            directory = "$(shorten-pwd)";
            symbol = " %{$fg[green]%}$%{$reset_color%}";
          in
          "${promptTime}${jobStatus}${directory}${symbol} ";
      in
      ''
        set -o ignoreeof

        export PATH="$PATH:$HOME/.bin:$HOME/.local/bin:$HOME/go/bin"

        function zvm_after_init() {
          if [[ $options[zle] = on ]]; then
            source ${pkgs.fzf}/share/fzf/completion.zsh
            source ${pkgs.fzf}/share/fzf/key-bindings.zsh

            eval "$(${pkgs.atuin}/bin/atuin init zsh --disable-up-arrow)"
            eval "$(${pkgs.navi}/bin/navi widget zsh)"
          fi
        }

        [ -f "$HOME/.zle_widgets" ] && source "$HOME/.zle_widgets"

        # Initialize ps1 after source zshfuncs since we're using it
        PS1='${PS1}'
      '';

    envExtra = ''
      [ -f "$HOME/.env" ] && source "$HOME/.env"
    '';

    profileExtra = '''';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.atuin = {
    enable = true;
    flags = [
      "--disable-up-arrow"
    ];
    # Will manually enable in the zsh initContent
    settings = {
      auto_sync = false;
      sync_address = "http://localhost:8080"; # Override dummy address
      show_help = false;
      show_tabs = false;
    };
  };

  programs.bat.enable = true;

  # A modern replacement for ‘ls’
  # useful in bash/zsh prompt, not in nushell.
  programs.eza = {
    enable = true;
    git = true;
    icons = "never";
    enableZshIntegration = true;
  };

  # terminal file manager
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      manager = {
        show_hidden = true;
        sort_dir_first = true;
      };
    };
  };

  # skim provides a single executable: sk.
  # Basically anywhere you would want to use grep, try sk instead.
  programs.skim = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.zshFunc = {
    shorten-pwd = {
      description = "Display current path in a shortened format";
      command = ''
        # Replace the home directory with ~ and split the path into an array using / as the delimiter
        local -a path_parts
        path_parts=("''${(@s:/:)''${PWD/#$HOME/~}}")

        # Process each element
        for i in {1..''$#path_parts}; do
          # Skip the home directory (~), empty elements, and the last element
          if [[ $path_parts[i] != "~" ]] && [[ -n $path_parts[i] ]] && (( i < $#path_parts )); then
            # Abbreviate the element to the first three characters and add ' '
            path_parts[i]=''${path_parts[i][1,3]}…
          fi
        done

        # Join the elements back into a string
        local new_path="''${(j:/:)path_parts}"
        echo "$new_path"
      '';
    };
    shorten-str = {
      description = "Short long string in a shortened format. `shorten-str 20 $str`";
      command = ''
        maxlen="$1"
        shift
        str="$@"

        # If the string length is less than or equal to maxlen, return the string as is
        if (( ''${#str} <= maxlen )); then
          echo $str
        else
          # Calculate the length to keep at the end of the string
          end_len=$((maxlen / 2))

          # Ensure that the total length is not more than maxlen
          start_len=$((maxlen - end_len - 1))

          echo "''${str:0:$start_len}…''${str: -end_len}"
        fi
      '';
    };
    unzipany = {
      description = "Unzip any archive type. `unzipany file.zip`";
      command = ''
        local input_file="$1"
        local output_dir="''${2:-''${input_file%.*}}" # Default output dir is input filename without extension

        if [[ ! -f "$input_file" ]]; then
          echo "Error: File '$input_file' not found!"
          return 1
        fi

        mkdir -p "$output_dir"

        case "$input_file" in
          *.tar.gz|*.tgz) ${pkgs.gnutar}/bin/tar -xzf "$input_file" -C "$output_dir" ;;
          *.tar.bz2|*.tbz2) ${pkgs.gnutar}/bin/tar -xjf "$input_file" -C "$output_dir" ;;
          *.tar.xz|*.txz) ${pkgs.gnutar}/bin/tar -xJf "$input_file" -C "$output_dir" ;;
          *.tar) ${pkgs.gnutar}/bin/tar -xf "$input_file" -C "$output_dir" ;;
          *.zip) ${pkgs.unzip}/bin/unzip -d "$output_dir" "$input_file" ;;
          *.rar) ${pkgs.unrar-wrapper}/bin/unrar x "$input_file" "$output_dir" ;;
          *.7z) ${pkgs.p7zip}/bin/7z x "$input_file" -o"$output_dir" ;;
          *.gz) ${pkgs.gzip}/bin/gunzip -c "$input_file" > "$output_dir/''${input_file%.*}" ;;
          *.bz2) ${pkgs.bzip2}/bin/bunzip2 -c "$input_file" > "$output_dir/''${input_file%.*}" ;;
          *.xz) ${pkgs.xz}/bin/unxz -c "$input_file" > "$output_dir/''${input_file%.*}" ;;
          *) echo "Error: Unsupported file format!" && return 1 ;;
        esac

        echo "Extraction completed: $output_dir"
      '';
    };
    flake-ignore = {
      description = "Ignore flake in git repository";
      command = ''
        if [ -f "flake.nix" ]; then
          git add --intent-to-add flake.nix
          git update-index --assume-unchanged flake.nix
        fi
        if [ -f "flake.lock" ]; then
          git add --intent-to-add flake.lock
          git update-index --assume-unchanged flake.lock
        fi
      '';
    };
    flake-undo-ignore = {
      description = "Ignore flake in git repository";
      command = ''
        if [ -f "flake.nix" ]; then
          git update-index assume-unchanged flake.nix
        fi
        if [ -f "flake.lock" ]; then
          git update-index assume-unchanged flake.lock
        fi
      '';
    };
    templates = {
      description = "Manage templates";
      command = ''
        # Match the first argument, list or echo.
        case "$1" in
          list)
            ls -1 "${configDir}/templates"
            ;;
          direnv)
            # Check if the second argument is provided
            if [ -z "$2" ]; then
              echo "Error: No template name provided."
              exit 1
            fi

            # Check if the template directory exists
            if [ ! -d "${configDir}/templates/$2" ]; then
              echo "Error: Template '$2' not found."
              exit 1
            fi

            # Print the content of the template directory
            echo "use flake \"\$FLAKE_TEMPLATES_DIR/$2\""
            ;;
          echo)
            # Check if the second argument is provided
            if [ -z "$2" ]; then
              echo "Error: No template name provided."
              exit 1
            fi

            # Check if the template file exists
            if [ ! -f "${configDir}/templates/$2/flake.nix" ]; then
              echo "Error: Template '$2' not found."
              exit 1
            fi

            # Print the content of the template file
            cat "${configDir}/templates/$2/flake.nix"
            ;;
          *)
            echo "Usage: templates [list|echo|direnv] [template_name]"
            ;;
        esac
      '';
    };
  };
}
