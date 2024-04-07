{ nixos-rebuild, nix, applyPatches, lib, nix-output-monitor, completion-file }:
let
  inherit (builtins) match;
  inherit (lib) elemAt makeBinPath;

  # make overridable by rebuild script
  newRebuild = nixos-rebuild.override { nix = nix.out; };

  patchedCompletionFile = applyPatches {
    name = "_nom-rebuild";
    src = completion-file;

    dontUnpack = true;

    patches = [ ./to-nom-rebuild-complition.patch ];

    patchPhase = ''
      for i in ''${patches[@]}; do
        patch $src $i -o $name
      done
    '';
    installPhase = "cp $name $out";
  };

  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/nixos-rebuild/default.nix#L23
  editSubstitutions = subs:
    let
      matches = match "^(.* 'path' '[^']*)('.*)$" subs;

      prefix = elemAt matches 0;
      suffix = elemAt matches 1;

      additionalPaths = makeBinPath [ nix-output-monitor ];
    in prefix + ":" + additionalPaths + suffix;

in newRebuild.overrideAttrs (old: {
  name = "nom-rebuild";
  substitutions = editSubstitutions old.substitutions;

  postInstall = ''
    patch $target ${./use-nom.patch}

    installShellCompletion \
      --bash ${patchedCompletionFile}
  '';
})
