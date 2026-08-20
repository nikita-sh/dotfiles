{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation {
  pname = "conduit";
  version = "0.4.0";

  src = fetchurl {
    url = "https://github.com/conduit-cli/conduit/releases/download/v0.4.0/conduit-aarch64-apple-darwin.tar.gz";
    sha256 = "18f4a98199fa3c8c4f9c747899f68f8e21ba7befd5e28b848ca5ae7086b8663f";
  };

  unpackPhase = ''
    runHook preUnpack
    tar -xzf "$src"
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 conduit "$out/bin/conduit"
    runHook postInstall
  '';

  meta = {
    description = "Run multiple coding agents in parallel";
    homepage = "https://getconduit.sh";
    license = lib.licenses.mit;
    mainProgram = "conduit";
    platforms = [ "aarch64-darwin" ];
  };
}
