{ prev }:
prev.latte-dock.overrideAttrs (old: {
  patches = old.patches ++ [ ./latte-dock.patch ];
  plasmaVersion = prev.libsForQt5.plasma-workspace.version;
  postPatch = ''
    substituteAllInPlace declarativeimports/core/environment.cpp
  '';
})
