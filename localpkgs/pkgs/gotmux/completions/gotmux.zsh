#compdef gotmux

_gotmux() {
    integer ret=1

    (( CURRENT == 2 )) || return ret

    local -a args
    args=($(tmuxp ls))

    _values "Installed tmuxp Configs" $args[@] && ret=0
    return ret
}

_gotmux
