{ config, lib, pkgs, inputs, ... }:
let
  inherit (lib) mkEnableOption mkOption mkIf types concatStringsSep optional;

  cfg = config.within.nix;
in {
  options.within.nix = {
    enable = mkEnableOption "nix config";
    emulatedSystems = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "emulated systems with qemu";
    };
    enablei686 = mkEnableOption "i686 platform";
  };

  config = mkIf cfg.enable {
    nix = {
      package = pkgs.nixVersions.latest;
      extraOptions = ''
        experimental-features = nix-command flakes auto-allocate-uids
        extra-platforms = ${
          concatStringsSep " "
          ((optional cfg.enablei686 "i686-linux") ++ cfg.emulatedSystems)
        }
        keep-outputs = true
        keep-derivations = true
      '';
      # Set nixpkgs channel to follow flake
      registry.nixpkgs.flake = inputs.nixpkgs;
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

      settings = {
        trusted-users = [ "root" ];

        substituters = [ "https://nix-community.cachix.org/" ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        auto-optimise-store = true;
      };

      gc = {
        automatic = true;
        options = "--delete-older-than 15d";
        dates = "monthly";
      };
    };

    nixpkgs.config = {
      allowUnfree = true;
      permittedInsecurePackages = [ ];
    };

    boot.binfmt.emulatedSystems = cfg.emulatedSystems;

    environment.systemPackages = [
      pkgs.nix-output-monitor

      # nix shell nixpkgs#{$1}
      ((pkgs.writeShellScriptBin "s" ''
        if [[ $# -eq 0 ]]; then
          echo "Usage: $0 <nixpkg> [<nixpkg> ...] [-- <command> [args...]]" >&2
          exit 1
        fi

        # Collect package attributes until we encounter "--" (if present).
        packages=()
        while [[ $# -gt 0 ]]; do
          case "$1" in
            --)
              shift
              break  # the rest (if any) belong to the command
              ;;
            *)
              packages+=("nixpkgs#$1")
              shift
              ;;
          esac
        done

        # Remaining arguments (if any) represent the command to run inside the env.
        cmd=("$@")

        if (( ''${#packages[@]} == 0 )); then
          echo "ERROR: At least one package must be specified before '--'." >&2
          exit 1
        fi

        # Construct the base argument list for `nix shell`.
        nix_args=(shell --impure "''${packages[@]}")

        # Append the user's command (if any) using `--command`.
        if (( ''${#cmd[@]} )); then
          nix_args+=(--command "''${cmd[@]}")
        fi

        # Replace the current process with the composed `nix` invocation.
        NIXPKGS_ALLOW_UNFREE=1 exec nix "''${nix_args[@]}"
      '').overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs or [ ]
          ++ [ pkgs.installShellFiles ];
        buildCommand = let
          completion = pkgs.writeText "s-completion" # bash
            ''
              #compdef s
              # ---------------------------------------------
              # Z-shell completion for the "s" wrapper
              # Delegates to upstream _nix but strips "nixpkgs#"
              # ---------------------------------------------

              autoload -Uz _nix            # from nix-zsh-completions

              _s() {
                # Complete any positional argument (1-indexed) that appears before an optional "--".
                # If completing options (after "--") bail out to allow default completion.
                # The index of the first literal "--" (if any); zero if not present.
                local dashdash_idx=''${words[(i)--]}

                # If we are positioned after the "--" delimiter, delegate completion to the
                # command located immediately after it (if any).
                if (( dashdash_idx && CURRENT > dashdash_idx )); then
                  # Identify the command (first word after --)
                  # dashdash_idx is 1-based; fetch the element after "--" safely with arithmetic expansion.
                  local cmd=''${words[$((dashdash_idx+1))]}

                  # If we are completing the command itself (cursor right after --), offer
                  # executable names.
                  if (( CURRENT == dashdash_idx + 1 )); then
                    _command_names -e
                    return
                  fi

                  # Otherwise, attempt to invoke that command's own completion function.
                  if [[ -n $cmd ]]; then
                    # Look for a completion function named _$cmd and call it in the proper
                    # context by temporarily rewriting $words / $CURRENT.
                    if whence -w "_$cmd" &>/dev/null; then
                      local -a save_words=(''${words[@]})
                      local save_current=$CURRENT

                      # Build new words array beginning with the command name followed by its args
                      words=("''${(@)words[@]:$((dashdash_idx))}")
                      CURRENT=$(( CURRENT - dashdash_idx ))

                      "_$cmd"  # call the command's completion function

                      # Restore original completion context
                      words=(''${save_words[@]})
                      CURRENT=$save_current
                      return
                    fi
                  fi

                  # Fallback to default completion behaviour if no specialised function.
                  _default
                  return
                fi

                # We only provide completions for arguments 2 .. N (packages), not for the command name itself.
                (( CURRENT >= 2 )) || return

                # Save original completion context
                local -a save_words=("''${words[@]}") _captured _cleaned
                local save_current=$CURRENT

                # Shadow compadd to capture matches from _nix
                function compadd {
                  while (( $# )); do
                    case $1 in
                      -a|-A) eval '_captured+=("''${'$2'[@]}")'; shift 2;;  # array matches
                      -X)    shift 2;;                                     # explanation text
                      -*)    shift;;                                        # other flags
                      *)     _captured+=("$1"); shift;;                    # literal matches
                    esac
                  done
                }

                # Pretend the user typed:  nix shell nixpkgs#<attr>  (where <attr> is the word under the cursor)
                words=(nix shell "nixpkgs#''${words[$CURRENT]}"); CURRENT=3; _nix

                # Restore original context
                unfunction compadd
                words=("''${save_words[@]}"); CURRENT=$save_current

                # Strip everything up to the last # (handles nixpkgs#s#foo cases)
                setopt localoptions no_extended_glob
                for m in "''${_captured[@]}"; do _cleaned+=("''${m##*#}"); done

                builtin compadd -Q -a _cleaned
              }
            '';
        in old.buildCommand + ''
          installShellCompletion --cmd s --zsh ${completion}
        '';
      }))

      # nix run nixpkgs#{$1}
      ((pkgs.writeShellScriptBin "x" ''
        if [ -z "$1" ]
        then
          echo "Usage: $0 {nixpkg}" 1>&2
          exit 1
        fi

        pkg="$1"
        shift

        NIXPKGS_ALLOW_UNFREE=1 exec nix --quiet run --impure "nixpkgs#$pkg" -- "$@"
      '').overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs or [ ]
          ++ [ pkgs.installShellFiles ];
        buildCommand = let
          completion = pkgs.writeText "x-completion" # bash
            ''
              #compdef x
              # ---------------------------------------------
              # Z-shell completion for the "x" wrapper
              # Delegates to upstream _nix but strips "nixpkgs#"
              # Only completes the first positional argument (package).
              # ---------------------------------------------

              autoload -Uz _nix            # from nix-zsh-completions

              _x() {
                # Only provide completions for the first positional argument (index 2).
                (( CURRENT == 2 )) || return

                # Save original completion context
                local -a save_words=("''${words[@]}") _captured _cleaned
                local save_current=$CURRENT

                # Shadow compadd to capture matches from _nix
                function compadd {
                  while (( $# )); do
                    case $1 in
                      -a|-A) eval '_captured+=("''${'$2'[@]}")'; shift 2;;  # array matches
                      -X)    shift 2;;                                     # explanation text
                      -*)    shift;;                                       # other flags
                      *)     _captured+=("$1"); shift;;                   # literal matches
                    esac
                  done
                }

                # Pretend the user typed:  nix shell nixpkgs#<attr>
                words=(nix shell "nixpkgs#''${words[$CURRENT]}"); CURRENT=3; _nix

                # Restore original context
                unfunction compadd
                words=("''${save_words[@]}"); CURRENT=$save_current

                # Strip everything up to the last # (handles nixpkgs#s#foo cases)
                setopt localoptions no_extended_glob
                for m in "''${_captured[@]}"; do _cleaned+=("''${m##*#}"); done

                builtin compadd -Q -a _cleaned
              }
            '';
        in old.buildCommand + ''
          installShellCompletion --cmd x --zsh ${completion}
        '';
      }))
    ];
  };
}
