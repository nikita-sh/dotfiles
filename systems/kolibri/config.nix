{ pkgs, ... }:
{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 10;
  };

  networking.hostName = "kolibri";

  programs = {
    dconf.enable = true;
    zsh.enable = true;
    ssh.startAgent = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;
    users."nikita".openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHX+C38gUcqJapP8sfb3PA2ErQli67Nu02iWQm6+qmEu nikita@falke"
    ];
  };

  services = {
    dbus.enable = true;
    openssh.enable = true;
    tailscale.enable = true;
    postgresql = {
      enable = true;
      authentication = pkgs.lib.mkOverride 10 ''
        #type database  DBuser  auth-method
        local all       all     trust
      '';
      ensureUsers = [
        {
          name = "nikita";
          ensureClauses.superuser = true;
        }
      ];
      ensureDatabases = [
        "conductor"
      ];
    };
  };

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
        supportedFeatures = [
          "benchmark"
          "big-parallel"
        ];
      }
    ];
  };

  security = {
    rtkit.enable = true;
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
}
