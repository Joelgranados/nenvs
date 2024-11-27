{
  shellHook = ''
    export _prompt_sorin_prefix="$_prompt_sorin_prefix%F{green}D"; \
    export SHELL=$(command -v zsh); \
    exec $SHELL;
  '';
}
