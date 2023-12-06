((import <nixpkgs> {}).buildFHSUserEnv {
  name = "eagle-env";
  targetPkgs = pkgs: 
       ( with pkgs; [ git gtk3 ncurses5 zlib libGL gobject-introspection glib nss nspr fontconfig freetype expat alsaLib ] )
    ++ ( with pkgs.xorg; [ libX11 libXcursor libXrandr libXext libXtst libXi libXrender libxcb ] );
  multiPkgs = pkgs: [];
  # runScript = "bash -c \"export _JAVA_AWT_WM_NONREPARENTING=1; bash\"";
  runScript = "bash";
}).env

