{ stdenv, lib, bzip2, patchelf, teensy-loader-cli, callPackage
, fetchurl, fetchFromGitHub, pkgconfig
}:

let
  teensy3-core = callPackage ./teensy3-core/default.nix {
    clockRate = 72000000;
    mcu       = "MK20DX256";
  };
in
  stdenv.mkDerivation rec {
    name    = "teensy-dev-${version}";
    version = "1.1.0";
    # src     = ./src;
     src     = ./.;

    buildInputs = [
      teensy-loader-cli
      teensy3-core
      pkgconfig
    ];
  }
