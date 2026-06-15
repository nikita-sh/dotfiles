# Mercury work-machine glue: bootstrap-mercury, fnm, Homebrew PATH.
{
  pkgs,
  inputs,
  system,
  ...
}:
{
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
    profileExtra = ''
      [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv zsh)"
    '';
  };
}
