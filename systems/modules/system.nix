{
  self,
  pkgs,
  inputs,
  ...
}:
{
  nix = {
    settings = {
      download-buffer-size = "100000000";
      trusted-users = [ "nikita" ];
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    distributedBuilds = true;
    extraOptions = ''
      builders-use-substitutes = true
      keep-outputs = true
      keep-derivations = true
      netrc-file = /etc/netrc
    '';
    buildMachines = [
      {
        hostName = "nixbuild.vital.company";
        system = "x86_64-linux";
        maxJobs = 64;
        speedFactor = 2;
        sshUser = "nikita";
        sshKey = "/home/nikita/.ssh/id_ed25519";
        supportedFeatures = [
          "benchmark"
          "big-parallel"
        ];
      }
      {
        hostName = "nixbuild.vital.company";
        system = "aarch64-linux";
        maxJobs = 64;
        speedFactor = 2;
        sshUser = "nikita";
        sshKey = "/home/nikita/.ssh/id_ed25519";
        supportedFeatures = [
          "benchmark"
          "big-parallel"
        ];
      }
      {
        hostName = "hydra-aarch64.vital.company";
        system = "aarch64-linux";
        maxJobs = 64;
        speedFactor = 2;
        sshUser = "nikita";
        # sshKey = "/home/nikita/.ssh/id_ed25519";
        supportedFeatures = [
          "benchmark"
          "big-parallel"
        ];
      }
      {
        hostName = "hydra-x86-64.vital.company";
        system = "x86_64-linux";
        maxJobs = 64;
        speedFactor = 2;
        sshUser = "nikita";
        # sshKey = "/home/nikita/.ssh/id_ed25519";
        supportedFeatures = [
          "benchmark"
          "big-parallel"
        ];
      }
    ];
  };

  # nixpkgs = {
  #   overlays = [
  #     # self.overlays.default
  #     inputs.nur.overlay
  #   ];
  # };

  # programs.ssh.extraConfig = ''
  #   Host *
  #     IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  # '';

  environment = {
    systemPackages = with pkgs; [
      wget
      git
      nil
    ];
    localBinInPath = true;
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_US.UTF-8";
  # system.stateVersion = "23.05";

  programs.ssh = {
    extraConfig = ''
      Host hydra-x8664
        Hostname hydra-x8664
        User nikita
        ForwardAgent yes
        IdentityFile /Users/nikita/.ssh/id_ed25519

      Host hydra-aarch64
        Hostname hydra-aarch64
        User nikita
        ForwardAgent yes
        IdentityFile /Users/nikita/.ssh/id_ed25519

      Host hydra-x86-64.vital.company
        Hostname hydra-x86-64.vital.company
        User nikita
        ForwardAgent yes
        IdentityFile /Users/nikita/.ssh/id_ed25519

      Host hydra-aarch64.vital.company
        Hostname hydra-aarch64.vital.company
        User nikita
        ForwardAgent yes
        IdentityFile /Users/nikita/.ssh/id_ed25519

      Host nixbuild.vital.company
        Port 2222
        PubkeyAcceptedKeyTypes ssh-ed25519
        ServerAliveInterval 60
        IPQoS throughput
        IdentityFile /home/nikita/.ssh/id_ed25519
    '';

    knownHosts = {
      nixbuild = {
        hostNames = [ "nixbuild.vital.company" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+jBIzENqxs/p7dFEAIjG8e5TT+A9Gvhi1cKNdIJ9vW";
      };
    };
  };
}
