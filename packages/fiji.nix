{ stdenv, fetchurl, adoptopenjdk-hotspot-bin-8, unzip, makeWrapper }:

stdenv.mkDerivation {
  pname = "fiji";
  version = "20170530";

  src = fetchurl {
    url = "https://downloads.imagej.net/fiji/Life-Line/fiji-nojre-20170530.zip";
    sha256 = "085xj0wfklg0rd275r1kr2lh18zpy5vq95krnj47hamj91fb97yg";
  };
  buildInputs = [ unzip makeWrapper ];
  inherit adoptopenjdk-hotspot-bin-8;

  # JAR files that are intended to be used by other packages
  # should go to $out/share/java.
  # (Some uses ij.jar as a library not as a standalone program.)
  installPhase = ''
    mkdir -p $out/share/java
    cp -dR jars/* $out/share/java
    cp -dR luts macros plugins $out/share
    mkdir $out/bin
    makeWrapper ${adoptopenjdk-hotspot-bin-8}/bin/java $out/bin/fiji \
      --add-flags "-jar $out/share/java/ij-1.51n.jar -ijpath $out/share"
  '';
}

