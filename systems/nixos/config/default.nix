let
  modules = [ (import ./bootloader.nix) ] ++ [ (import ./hardware.nix) ]
    ++ [ (import ./xserver.nix) ] ++ [ (import ./network.nix) ]
    ++ [ (import ./pipewire.nix) ] ++ [
      (import ./program.nix)
    ]
    # ++ [ (import ./../home/package/python.nix) ]
    ++ [ (import ./security.nix) ] ++ [ (import ./services.nix) ]
    ++ [ (import ./system.nix) ] ++ [ (import ./wayland.nix) ]
    ++ [ (import ./office-vpn.nix) ] ++ [ (import ./software-workstation.nix) ]
    ++ [ (import ./thinkpad.nix) ] ++ [ (import ./probe-rs.nix) ]
    ++ [ (import ./vpn.nix) ] ++ [ (import ./virtualization.nix) ]
    ++ [ (import ./user.nix) ] ++ [ ./hardware-configuration.nix ];
in modules
