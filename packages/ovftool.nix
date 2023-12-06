{ stdenv, lib, requireFile, writeScript, writeShellScript, callPackage
, bash, bubblewrap, zlib
}:

let
  src-filename = "VMware-ovftool-4.4.0-16360108-lin.x86_64.bundle";
  src = requireFile {
    name   = src-filename;
    url    = "https://my.vmware.com/group/vmware/downloads/get-download?downloadGroup=OVFTOOL440P01";
    sha256 = "53f7dcf8b26c881fe7e6eedb17865601b32ae20b2ee04d3f74744d5f593448ca";
  };

  buildFHSEnv = callPackage ./env.nix {};

  etcBindFlags = let
    files = [
      # NixOS Compatibility
      "static"
      # Users, Groups, NSS
      "passwd"
      "group"
      "shadow"
      "hosts"
      "resolv.conf"
      "nsswitch.conf"
      # Sudo & Su
      "login.defs"
      "sudoers"
      "sudoers.d"
      # Time
      "localtime"
      "zoneinfo"
      # Other Core Stuff
      "machine-id"
      "os-release"
      # PAM
      "pam.d"
      # Fonts
      "fonts"
      # SSL
      "ssl/certs"
      "pki"
    ];
  in builtins.concatStringsSep " \\\n  "
  (map (file: "--ro-bind-try /etc/${file} /etc/${file}") files);

  env = buildFHSEnv {
    name = "vmware-ovftool-unpacker-env";
    targetPkgs = pkgs: 
      # FIXME not minimal
         ( with pkgs; [ git gtk3 ncurses5 zlib libGL gobject-introspection glib nss nspr fontconfig freetype expat ] )
      ++ ( with pkgs.xorg; [ libX11 libXcursor libXrandr libXext libXtst libXi libXrender libxcb ] );
    multiPkgs = pkgs: [];
  };

  unpackerScript = writeShellScript "vmware-ovftool-unpacker-script" ''
    echo in script
    source /etc/profile
    cp ${src} /unpack/bundle
    chmod +x /unpack/bundle
    /unpack/bundle -x /unpack/unpacked
    echo out script
  '';

  unpacked = stdenv.mkDerivation {
    name = "ovftool-unpacked";
    preferLocalBuild = true;
    builder = writeShellScript "unpack-ovftool" ''
      source ${stdenv}/setup

      blacklist="/nix /dev /proc /etc"
      ro_mounts=""
      for i in ${env}/*; do
        path="/''${i##*/}"
        if [[ $path == '/etc' ]]; then
          continue
        fi
        ro_mounts="$ro_mounts --ro-bind $i $path"
        blacklist="$blacklist $path"
      done

      if [[ -d ${env}/etc ]]; then
        for i in ${env}/etc/*; do
          path="/''${i##*/}"
          ro_mounts="$ro_mounts --ro-bind $i /etc$path"
        done
      fi

      auto_mounts=""
      # loop through all directories in the root
      for dir in /*; do
        # if it is a directory and it is not in the blacklist
        if [[ -d "$dir" ]] && grep -v "$dir" <<< "$blacklist" >/dev/null; then
          # add it to the mount list
          auto_mounts="$auto_mounts --bind $dir $dir"
        fi
      done

      mkdir "$out"
      ${bubblewrap}/bin/bwrap \
        --dev-bind /dev /dev \
        --proc /proc \
        --chdir "$(pwd)" \
        --unshare-all \
        --share-net \
        --die-with-parent \
        --ro-bind /nix /nix \
        ${etcBindFlags} \
        $ro_mounts \
        $auto_mounts \
        --bind "$out" /unpack \
        ${unpackerScript}
      '';
  };
in
  stdenv.mkDerivation rec {
    pname = "ovftool";
    version = "4.4.0-16360108";

    builder = writeShellScript "ovftool-build" ''
      source ${stdenv}/setup

      cp -R "${unpacked}/unpacked/vmware-ovftool" $out
      chmod +xw $out
      chmod +w $out/*
      chmod +x $out/*.so*
      chmod +x $out/ovftool
      chmod +x $out/ovftool.bin
      sed -i -e 's,readlink "$PRG",readlink -f "$PRG",g' $out/ovftool
      mkdir -p $out/bin
      ln -s $out/ovftool $out/bin/ovftool
      patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$out/ovftool.bin"
      patchelf --set-rpath "$out:$out:${lib.strings.makeLibraryPath [ stdenv.cc.cc zlib ]}" "$out/ovftool.bin"
      patchShebangs "$out"
    '';

    meta = {
      license = lib.licenses.unfree;
      platform = ["x86_64-linux"];
    };
  }
