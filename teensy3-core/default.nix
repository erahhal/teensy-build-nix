{ stdenv, lib, bzip2, dpkg, patchelf, glibc, gcc, fetchurl, fetchFromGitHub, writeTextFile, clockRate, mcu }:

with lib;
let
  version = "4.7-2013q3-20130916";
  releaseType = "update";
  gcc-arm-embedded-sha256 = "1bd9bi9q80xn2rpy0rn1vvj70rh15kb7dmah0qs4q2rv78fqj40d";
  versionParts = splitString "-" version; # 4.7 2013q3 20130916
  majorVersion = elemAt versionParts 0; # 4.7
  yearQuarter = elemAt versionParts 1; # 2013q3
  underscoreVersion = replaceChars ["."] ["_"] version; # 4_7-2013q3-20130916
  yearQuarterParts = splitString "q" yearQuarter; # 2013 3
  year = elemAt yearQuarterParts 0; # 2013
  quarter = elemAt yearQuarterParts 1; # 3
  subdirName = "${majorVersion}-${year}-q${quarter}-${releaseType}"; # 4.7-2013-q3-update
in
let
  gcc-arm-embedded-4_7 = stdenv.mkDerivation {
    name = "gcc-arm-embedded";

    srcs = [
      (fetchurl {
        url = "https://launchpad.net/gcc-arm-embedded/${majorVersion}/${subdirName}/+download/gcc-arm-none-eabi-${underscoreVersion}-linux.tar.bz2";
        sha256 = gcc-arm-embedded-sha256;
      })
      (fetchurl {
        url = "https://cloudfront.debian.net/debian-archive/debian/pool/main/e/eglibc/libc6-i686_2.13-38+deb7u10_i386.deb";
        sha256 = "0djjcpnjimjbh1wm7ggblbzd4ln1jirnc3hdmqbms5b443g3ldnm";
      })
    ];

    buildInputs = [ bzip2 dpkg patchelf ];
   
    dontPatchELF = true;
    
    phases = "unpackPhase patchPhase installPhase";

    unpackPhase = ''
      for srcFile in $srcs; do
        cp $srcFile $(stripHash $srcFile)
      done
      dpkg -x libc6-i686_2.13-38+deb7u10_i386.deb libc6-i386
      rm libc6-i686_2.13-38+deb7u10_i386.deb
      tar xvjf gcc-arm-none-eabi-4_7-2013q3-20130916-linux.tar.bz2 --strip-components=1
      rm gcc-arm-none-eabi-4_7-2013q3-20130916-linux.tar.bz2
    '';
    
    installPhase = ''
      mkdir -pv $out
      cp -r ./* $out

      for f in $(find $out); do
        if [ -f "$f" ] && patchelf "$f" 2> /dev/null; then
          patchelf --set-interpreter $out/libc6-i386/lib/i386-linux-gnu/i686/cmov/ld-linux.so.2 \
                   --set-rpath $out/lib:$out/libc6-i386/lib/i386-linux-gnu/i686/cmov \
                   "$f" || true
        fi
      done
    '';
  };
in
let
  linkerScript = (lib.toLower mcu) + ".ld";
in
  stdenv.mkDerivation rec {
    # name    = "teensy3-core-${version}";
    # version = "1.56";
    # src  = fetchFromGitHub {
    #   owner  = "PaulStoffregen";
    #   repo   = "cores";
    #   rev    = version;
    #   sha256 = "1yfam4rbgsyazi81y4qph8wzwskjf89jjs33q9l8vd2xcy0yi0yl";
    # };
    name    = "teensy3-core-${version}";
    version = "random-patched";
    src  = fetchFromGitHub {
      owner  = "erahhal";
      repo   = "cores";
      rev    = version;
      sha256 = "19gksarw4dnxsil4gk018wihhpl7jq7c8i2d4p51qqw3216ijd72";
    };

    buildInputs = [
      gcc-arm-embedded-4_7
    ];

    phases = ["unpackPhase" "buildPhase" "installPhase"];

    buildPhase = ''
      rm -f teensy3/main.cpp

      substitute ${./flags.mk} ./teensy3/flags.mk \
        --subst-var-by clockRate ${toString clockRate} \
        --subst-var-by mcu ${mcu}

      substitute ${./Makefile} ./teensy3/Makefile \
        --subst-var-by linkerScript ${linkerScript}

      make -C teensy3
      ar rvs libteensy3-core.a *.o
    '';

    installPhase = ''
      mkdir -p $out/{include,lib}
      mkdir $out/lib/pkgconfig

      mv *.a $out/lib
      cp teensy3/* $out/include -R;

      rm $(find $out -name "*.c" -o -name "*.cpp")

      substitute ${./teensy3-core.pc} $out/lib/pkgconfig/teensy3-core.pc \
        --subst-var-by out $out \
        --subst-var-by version ${version} \
        --subst-var-by linkerScript ${linkerScript}
    '';
  }
