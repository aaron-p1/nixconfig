{ latte-dock, fetchurl, ... }:
latte-dock.overrideAttrs (old: rec {
  version = "0.10.3";

  src = fetchurl {
    url = "https://download.kde.org/stable/${old.pname}/${old.pname}-${version}.tar.xz";
    sha256 = "12wschkkp5dslnxmfdnfld2x54mca7kqyyi7f9yavz5q9xdf7a4a";
    name = "${old.pname}-${version}.tar.xz";
  };
})
