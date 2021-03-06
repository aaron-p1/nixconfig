#!/usr/env bash

_gotmux() {
  local files

  (( COMP_CWORD == 1 )) || return

  files="$(tmuxp ls)"

  mapfile -t COMPREPLY < <(compgen -W "$files" -- "${COMP_WORDS[COMP_CWORD]}")
}

complete -F _gotmux gotmux
