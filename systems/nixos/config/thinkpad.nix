{ config, pkgs, ... }:

let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in {
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  environment.systemPackages = with pkgs; [ bluez-tools nvidia-offload ];

  hardware = {
    #bluetooth = {
    #  enable = true;
    #  package = pkgs.bluez;
    #};

    nvidia = {
      modesetting.enable = true;
      prime = {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    opengl.extraPackages =
      [ pkgs.mesa.drivers pkgs.linuxPackages.nvidia_x11.out ];

    # pulseaudio.enable = false;
  };

  # sound.enable = true;

  services = {
    blueman.enable = true;

    # xserver = {
    #   dpi = 192;
    #   videoDrivers = [ "nvidia" ];
    # };
  };
}

