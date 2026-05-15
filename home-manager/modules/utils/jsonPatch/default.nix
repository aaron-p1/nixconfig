{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) attrValues toJSON;
  inherit (lib)
    mkIf
    types
    mkOption
    literalExpression
    filterAttrs
    hm
    isFunction
    escapeShellArg
    concatStringsSep
    ;

  cfg = config.home.jsonPatch;

  # the `$PATCH$[...]` keys must be the same as in patch.jq
  ops = {
    # Unset value in object or array.
    # Example: { key = ops.unset }
    unset = {
      "$PATCH$unset" = true;
    };
    # Replace object instead of merging.
    # Example: { object = ops.replace { new = "value"; } }
    replace = newValue: {
      "$PATCH$replace" = newValue;
    };
    # Append to array instead of replacing.
    # Only non existing values will be appended, so this is idempotent.
    # Example: { array = ops.append [ "new" "values" ] }
    append = values: {
      "$PATCH$append" = values;
    };
    # Patch element at index in array.
    # Example: { array = ops.atIndex { "0" = "new value"; "2" = ops.unset } }
    atIndex = value: {
      "$PATCH$at" = value;
    };
    # Patch array element with matching field value.
    # Example: { array = ops.byField { id.clock = { timezone = "UTC"; }; } }
    # value is { fieldName.fieldValue = patch; }
    byField = value: {
      "$PATCH$byField" = value;
    };
  };

  patchType = types.submodule (
    { name, config, ... }:
    {
      options = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Whether this JSON patch is active.";
        };

        target = mkOption {
          type = types.str;
          default = name;
          defaultText = literalExpression "name";
          description = ''
            Path of the JSON file to patch, relative to $HOME.
          '';
        };

        patch = mkOption {
          type = types.either (types.functionTo types.anything) types.anything;
          description = ''
            Patch to apply to `target`. Can be any value that can be converted to json
            or a function that takes single arg `ops` (an attrset that has patching
            operation functions) and returns the json patch to apply.
          '';
          default = null;
        };

        source = mkOption {
          type = types.path;
          description = ''
            Path to a JSON file to merge into the target.
            If `patch` is non-null then this option will automatically point to a
            file containing that text.
          '';
        };
      };

      config = {
        source =
          let
            inherit (config) patch;
            patchAttrs = if (isFunction patch) then patch ops else patch;
          in
          mkIf (patchAttrs != null) (
            pkgs.writeTextFile {
              text = toJSON patchAttrs;
              name = hm.strings.storeFileName name;
            }
          );
      };
    }
  );

  enabledPatches = attrValues (filterAttrs (_: p: p.enable) cfg);

  # Bash associative array literal: target -> patch file
  patchMap = concatStringsSep "\n" (
    map (file: "  [${escapeShellArg file.target}]=${escapeShellArg "${file.source}"}") enabledPatches
  );
in
{
  _class = "homeManager";

  options.home.jsonPatch = mkOption {
    type = types.attrsOf patchType;
    default = { };
    description = ''
      Similar to `home.file`, but for patching existing JSON files.
      Files are patched at activation.
    '';
    example = literalExpression ''
      {
        ".config/foo/settings.json" = {
          patch = { theme = "dark"; };
        };
        ".config/bar/config.json".patch = ops: {
          # replaces the `timezone` field of a widget with `id == "clock"` in `widgets` array
          widgets: ops.byField { id.clock = { timezone = "UTC"; }; };
        };
      }
    '';
  };

  config = mkIf (enabledPatches != [ ]) {
    home.activation.applyJsonPatches =
      hm.dag.entryAfter [ "linkGeneration" ] # bash
        ''
          declare -A patches=(
          ${patchMap}
          )

          for target in "''${!patches[@]}"; do
            targetPath="$HOME/$target"
            [ -f "$targetPath" ] || continue
            patchPath="''${patches[$target]}"

            temp="$(${pkgs.coreutils}/bin/mktemp)"

            ${pkgs.jq}/bin/jq \
              -f ${./patch.jq} \
              --slurpfile patch "$patchPath" \
              "$targetPath" > "$temp"

            ${pkgs.coreutils}/bin/mv "$temp" "$targetPath"
          done
        '';
  };
}
