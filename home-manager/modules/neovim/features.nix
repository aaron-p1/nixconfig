{ lib, ... }: {
  within.neovim.configDomains.features = {
    config = let
      inherit (builtins) readFile;
      inherit (lib) pipe mapAttrs mapAttrsToList concatStringsSep;

      features = {
        fh = ./features/fhighlight.lua;
        ei = ./features/edit_injection.lua;
        st = ./features/swap_textobjects.lua;
        cm = ./features/changed_marks.lua;
      };

      featureFunctions = pipe features [
        (mapAttrs (name: readFile))

        (mapAttrsToList (name: content: # lua
          ''
            local function _${name}()
              ${content}
            end

            local ${name} = _${name}()
          ''))

        (concatStringsSep "\n\n")
      ];
    in featureFunctions;
  };
}
