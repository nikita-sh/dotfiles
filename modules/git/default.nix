{ pkgs, ... }: {
  programs.git = {
    enable = true;

    userName = "Nikita Shumeiko";
    userEmail = "nikita.shumeiko@vitalbio.com";
    aliases = {
      p = "pull";
      pr = "pull --rebase";
      psh = "push";
      ci = "commit";
      ca = "commit --amend";
      cim = "commit -m";
      s = "status";
      st = "stash";
      pfwl = "push --force-with-lease";
      co = "checkout";
      cob = "checkout -b";
      r = "rebase";
      rbi = "rebase -i";
      a = "add";
      sp = "stash pop";
      cp = "cherry-pick";
      l = "log";
      d = "diff";
      rl = "reflog";
      m = "merge";
      rb = "rebase";
    };
    extraConfig = {
      core.editor = "$EDITOR";
      core.pager = "${pkgs.delta}/bin/delta";
      interactive.diffFilter = "${pkgs.delta}/bin/delta --color-only";
      add.interactive.useBuiltin = false;
      delta = {
        features = "chameleon";
        side-by-side = false;
        navigate = true;
        light = false;
      };
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };

  home.packages = [ pkgs.gh ];
}
