# Mercury work-machine glue: bootstrap-mercury, fnm, Homebrew PATH.
{
  config,
  pkgs,
  inputs,
  system,
  ...
}:
{
  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  my.sessionVariables.NODE_EXTRA_CA_CERTS = "${config.home.homeDirectory}/.pi/agent/mercury-root-cas.pem";

  home.packages = [
    pkgs.fnm
    inputs.bootstrap-mercury.packages.${system}.default # bin/bootstrap-mercury
  ];

  programs.zsh = {
    # bootstrap-mercury probes `zsh -i -c '[ -n "$FNM_MULTISHELL_PATH" ]'`;
    # having this in .zshrc makes that check pass so it never appends its own
    # init lines to the rc files home-manager owns.
    initContent = ''
      eval "$(fnm env --use-on-cd --corepack-enabled)"
    '';

    # home-manager only writes ~/.zprofile when profileExtra is set; claiming
    # it here keeps bootstrap-mercury (and anything else) from owning it.
    #
    # The nix sourcing can't live in /etc: macOS updates strip the installer's
    # hook from /etc/zshrc, the Determinate /etc/zshenv hook only fires for
    # SSH sessions, and nix-darwin is not active on this machine. Sourcing it
    # after brew keeps nix ahead of Homebrew in PATH.
    profileExtra = ''
      [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv zsh)"
      if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi
    '';
  };
}
