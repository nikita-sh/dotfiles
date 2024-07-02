{ pkgs, lib, ... }: {
  home.packages = with pkgs;
    [
      (pkgs.slack.overrideAttrs (oldAttrs: rec {
        # version = "4.35.126";
        # src = pkgs.fetchurl {
        #   url =
        #     "https://downloads.slack-edge.com/releases/linux/${version}/prod/x64/slack-desktop-${version}-amd64.deb";
        #   sha256 = "sha256-ldFASntF8ygu657WXwk/XlpHzB+S9x8SjAOjjDKsvCs=";
        # };

        fixupPhase = ''
          sed -i -e 's/,"WebRTCPipeWireCapturer"/,"LebRTCPipeWireCapturer"/' $out/lib/slack/resources/app.asar

          rm $out/bin/slack
          makeWrapper $out/lib/slack/slack $out/bin/slack \
            --prefix XDG_DATA_DIRS : $GSETTINGS_SCHEMAS_PATH \
            --suffix PATH : ${lib.makeBinPath [ pkgs.xdg-utils ]} \
            --add-flags "--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer"
        '';
      }))
    ];
}
