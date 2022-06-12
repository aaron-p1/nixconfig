#compdef initdev

_initdev() {
  integer ret=1

  (( CURRENT == 2 )) || return ret

  local -a args
  args=(any dart elixir jupyter-python npm phoenix python yarn)

  _values "Installed dev env Configs" $args[@] && ret=0
  return ret
}

_initdev
