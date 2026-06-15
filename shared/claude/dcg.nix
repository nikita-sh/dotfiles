{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
}:
let
  version = "0.6.7";
  sources = {
    aarch64-darwin = {
      asset = "dcg-aarch64-apple-darwin.tar.xz";
      hash = "sha256-3M/ZDb13p1RkeErpC+EOQ1bPAYVnCMqFBuy1bafnXn8=";
    };
    x86_64-darwin = {
      asset = "dcg-x86_64-apple-darwin.tar.xz";
      hash = "sha256-SBg1nljSGHIWDtVpiE7WQZNdX3Qii60wzR+qTUPBFYQ=";
    };
    x86_64-linux = {
      # musl build, fully static
      asset = "dcg-x86_64-unknown-linux-musl.tar.xz";
      hash = "sha256-bZB1S3FwvetjN1/X0g59wzDFa48QGPxFzLvVzMwcoYM=";
    };
    aarch64-linux = {
      # gnu build, dynamically linked -> autoPatchelfHook
      asset = "dcg-aarch64-unknown-linux-gnu.tar.xz";
      hash = "sha256-nZ7bVBoDwEl+RHLlymF0fUdjV87Qd9tFK7SBHO5ct34=";
    };
  };
  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "dcg: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "dcg";
  inherit version;

  src = fetchurl {
    url = "https://github.com/Dicklesworthstone/destructive_command_guard/releases/download/v${version}/${source.asset}";
    inherit (source) hash;
  };

  # The tarball contains a single `dcg` binary at its root.
  sourceRoot = ".";

  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 dcg $out/bin/dcg
    runHook postInstall
  '';

  meta = {
    description = "PreToolUse guard that blocks destructive shell commands in AI coding agents";
    homepage = "https://github.com/Dicklesworthstone/destructive_command_guard";
    mainProgram = "dcg";
    platforms = builtins.attrNames sources;
  };
}
