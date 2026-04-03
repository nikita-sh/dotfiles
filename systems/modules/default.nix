{
  inputs,
  nixpkgs,
  self,
  hname,
  ...
}:
{
  nixos = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit
        self
        inputs
        hname
        ;
    };
    modules = [
      inputs.vscode-server.nixosModules.default
      (
        { config, pkgs, ... }:
        {
          services.vscode-server = {
            enable = true;
            enableFHS = true;
          };
        }
      )
    ]
    ++ [
      (import ./bootloader.nix)
    ]
    ++ [ (import ./hardware.nix) ]
    ++ [ (import ./xserver.nix) ]
    ++ [ (import ./network.nix) ]
    ++ [ (import ./pipewire.nix) ]
    ++ [ (import ./program.nix) ]
    ++ [ (import ./security.nix) ]
    ++ [ (import ./services.nix) ]
    ++ [ (import ./system.nix) ]
    ++ [ (import ./wayland.nix) ]
    ++ [ (import ./office-vpn.nix) ]
    ++ [ (import ./software-workstation.nix) ]
    ++ [ (import ./thinkpad.nix) ]
    ++ [ (import ./probe-rs.nix) ]
    ++ [
      (import ./vpn.nix)
    ]
    ++ [ (import ./virtualization.nix) ]
    ++ [ (import ./hardware.nix) ]
    ++ [ (import /home/nikita/dev/vital-nix/vm/software-workstation.nix) ]
    ++ [ (import /home/nikita/dev/vital-nix/vm/conductor.nix) ];
  };
}
