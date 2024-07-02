{ self, pkgs, inputs, ... }: {
  # imports = [ inputs.nix-gaming.nixosModules.default ];
  nix = {
    settings = {
      trusted-users = [ "nikita" ];
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [ "https://nix-gaming.cachix.org" ];
      trusted-public-keys = [
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    distributedBuilds = true;
    # https://github.com/nix-community/nix-direnv
    extraOptions = ''
      builders-use-substitutes = true
      keep-outputs = true
      keep-derivations = true
    '';
    buildMachines = [{
      hostName = "hydra-aarch64.vital.company";
      sshUser = "nikita";
      sshKey = "/home/nikita/.ssh/id_rsa";
      system = "aarch64-linux";
      maxJobs = 4;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }];
  };
  nixpkgs = { overlays = [ inputs.nur.overlay ]; };

  environment.systemPackages = with pkgs; [ wget git ];

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "electron-25.9.0" ];
  };

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "23.05";
}
