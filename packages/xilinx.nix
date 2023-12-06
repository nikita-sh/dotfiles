((import <nixpkgs> {}).buildFHSUserEnv {
  name = "xilinx-env";
  targetPkgs = pkgs: 
       ( with pkgs; [ git gtk3 ncurses5 zlib ] )
    ++ ( with pkgs.xorg; [ libX11 libXcursor libXrandr libXext libXtst libXi libXrender ] );
  multiPkgs = pkgs: [];
  # runScript = "bash -c \"export _JAVA_AWT_WM_NONREPARENTING=1; bash\"";
  runScript = "bash";
}).env

