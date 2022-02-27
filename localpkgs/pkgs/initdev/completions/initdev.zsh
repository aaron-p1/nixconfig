#compdef initdev

_initdev() {
  integer ret=1

  (( CURRENT == 2 )) || return ret

  local -a args
  args=(elixir phoenix)

  _values "Installed dev env Configs" $args[@] && ret=0
  return ret
}

_initdev
