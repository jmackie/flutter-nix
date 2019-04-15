{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  name = "flutter";
  version = "v1.2.1-stable";
  src = fetchTarball {
    url = "https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_${version}.tar.xz";
    sha256 = "1br6s5fbrv08i5cdp1b9p0i80wagvmfqk45938nczyybvyq9qars";
  };

  dontStrip = true;

  libPath = pkgs.lib.makeLibraryPath [
    pkgs.stdenv.cc.cc
  ];

  buildPhase = ''
    # Rewrite the `flutter` script
    echo 'HERE="$(dirname "$(realpath -s $0)")"' > bin/flutter
    echo '"$HERE/cache/dart-sdk/bin/dart" "$HERE/cache/flutter_tools.snapshot" "$@"' >> bin/flutter

    # Not needed
    rm bin/flutter.bat
  '';

  installPhase = ''
    mkdir $out
    cp -r . $out
  '';

  postFixup = ''
    patchelf \
      --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath $libPath \
      $out/bin/cache/dart-sdk/bin/dart
  '';
}
