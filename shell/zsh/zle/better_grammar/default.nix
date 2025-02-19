{ pkgs, ... }:
{
  imports = [
    ../../../../modules/zleFunc
  ];

  programs.zleCommands = {
    fix-grammar-with-openai = {
      command =
        let
          pythonEnv = pkgs.python312.withPackages (ps: with ps; [
            openai
            pydantic
          ]);
          python = "${pythonEnv}/bin/python";
          better_grammar_py = toString ./better_grammar.py;
        in
        ''
          zle -R "[Fixing grammar with OpenAI...]"

          if [[ -z ''$BUFFER ]]; then
            zle -R "[No input provided.]"
            return
          fi

          local current_input="''${LBUFFER}''${RBUFFER}"
          local fixed_text=''$(${python} ${better_grammar_py} ''$current_input)

          LBUFFER="''${fixed_text}"
          RBUFFER=""
        '';
      bindkeys = ''
        bindkey -M viins '^X^o' fix-grammar-with-openai
        bindkey -M viins '^Xo' fix-grammar-with-openai
      '';
    };
  };
}
