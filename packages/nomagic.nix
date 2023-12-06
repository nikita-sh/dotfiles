let pkgs = import <nixpkgs> {}; in
(pkgs.buildFHSUserEnv {
  name = "nomagic-env";
  targetPkgs = p: 
       ( with p; [ git gtk3 ncurses5 zlib adoptopenjdk-hotspot-bin-8 ] )
    ++ ( with p.xorg; [ libX11 libXcursor libXrandr libXext libXtst libXi libXrender ] );
  multiPkgs = ps: [];
  runScript = "bash -c \"export JAVA_HOME=${pkgs.adoptopenjdk-hotspot-bin-8}; bash\"";
}).env

