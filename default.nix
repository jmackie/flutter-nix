{ pkgs ? import <nixpkgs> {} }:
rec {
  engine = pkgs.stdenv.mkDerivation rec {
    name = "flutter-engine";
    version = "9aa7c9a48e9342a450c3078e15c8d7923a338ede";
    src = pkgs.fetchzip {
      url = "https://storage.googleapis.com/flutter_infra/flutter/${version}/dart-sdk-linux-x64.zip";
      sha256 = "19jqhvb4h65slmj2i1v8h7iwj3nphj0g0px30lvk4wg544dshrpz";
    };
    libPath = pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc ];
    dontConfigure = true;
    dontStrip = true;

    installPhase = ''
      mkdir $out
      cp -r . $out
    '';

    postFixup = ''
      patchelf \
        --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath $libPath \
        $out/bin/dart
    '';
  };

  flutter =
    let rev = "6c7b6833c928a68650021d90ae9c0b15f4a35946";
    in pkgs.stdenv.mkDerivation rec {
      name = "flutter";
      version = "v1.4.19";
      src = pkgs.fetchgit {
        url = "https://github.com/flutter/flutter.git";
        inherit rev;
        sha256 = "00w82qfj5d02681hsdv4ily1l8z8fsm07gx5mn3zgwcsgapvvwyn";
        leaveDotGit = true; # Important: flutter needs this to work...
      };
      dontConfigure = true;
      dontStrip = true;

      # Install engine and prevent cache invalidation
      buildPhase = ''
        mkdir -p bin/cache/dart-sdk
    	cp -r ${engine}/* bin/cache/dart-sdk         # $DART_SDK_PATH
        echo ${rev} > bin/cache/flutter_tools.stamp  # $STAMP_PATH

        touch packages/flutter_tools/pubspec.lock    # FIXME: this effect doesn't persist
      '';

      installPhase = ''
    	  mkdir $out
    	  cp -r . $out
      '';
    };
}
