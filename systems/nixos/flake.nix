{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit self inputs; };
      modules = [ (import ./config/hardware-configuration.nix) ]
        ++ [ (import ./config/bootloader.nix) ]
        ++ [ (import ./config/hardware.nix) ]
        ++ [ (import ./config/xserver.nix) ]
        ++ [ (import ./config/network.nix) ]
        ++ [ (import ./config/pipewire.nix) ]
        ++ [ (import ./config/program.nix) ]
        ++ [ (import ./config/security.nix) ]
        ++ [ (import ./config/services.nix) ]
        ++ [ (import ./config/system.nix) ] ++ [ (import ./config/wayland.nix) ]
        ++ [ (import ./config/office-vpn.nix) ]
        ++ [ (import ./config/software-workstation.nix) ]
        ++ [ (import ./config/thinkpad.nix) ]
        ++ [ (import ./config/probe-rs.nix) ] ++ [ (import ./config/vpn.nix) ]
        ++ [ (import ./config/virtualization.nix) ]
        ++ [ (import ./config/user.nix) ];
    };
  };
}
