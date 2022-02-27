#!/usr/env bash

_initdev() {
  local files

  (( COMP_CWORD == 1 )) || return

  files="elixir phoenix"

  mapfile -t COMPREPLY < <(compgen -W "$files" -- "${COMP_WORDS[COMP_CWORD]}")
}

complete -F _gotmux gotmux
