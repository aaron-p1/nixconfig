{
  stdenv,
  fetchFromGitHub,
  python3,
  ...
}:
stdenv.mkDerivation rec {
  pname = "ff2mpv-native-client";
  version = "3.8.0";

  src = fetchFromGitHub {
    owner = "woodruffw";
    repo = "ff2mpv";
    rev = "v${version}";
    sha256 = "sha256-eukkc9FdngueKR7ZfXdUry0BGC23FULEN966cEz8vvY=";
  };

  buildInputs = [ python3 ];

  patchPhase = ''
    patchShebangs ff2mpv.py

    substituteInPlace ff2mpv.json \
      --replace "/home/william/scripts/ff2mpv" "$out/bin/ff2mpv.py"
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -v ff2mpv.py $out/bin

    mkdir -p $out/lib/mozilla/native-messaging-hosts
    cp -v ff2mpv.json $out/lib/mozilla/native-messaging-hosts
  '';
}
