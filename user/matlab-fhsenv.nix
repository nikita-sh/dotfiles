((import <nixpkgs> {}).buildFHSUserEnv {
  name = "matlab-env";
  targetPkgs = pkgs: 
       ( with pkgs; [ alsaLib atk cairo cups dbus fontconfig git gdk-pixbuf glib gtk3 libselinux libudev ncurses5 nspr nss pam pango zlib ] )
    ++ ( with pkgs.xorg; [ libxcb libX11 libXcomposite libXcursor libXdamage libXfixes libXft libXinerama libXrandr libXext libXt libXtst libXi libXrender ] );
  multiPkgs = pkgs: [];
  # runScript = "bash -c \"export _JAVA_AWT_WM_NONREPARENTING=1; bash\"";
  runScript = "bash";
}).env

