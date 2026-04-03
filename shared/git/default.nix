{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Nikita Shumeiko";
        email = "nikita.shumeiko@vitalbio.com";
      };

      alias = {
        p = "pull";
        pr = "pull --rebase";
        psh = "push";
        c = "commit";
        ca = "commit --amend";
        cm = "commit -m";
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
      init.defaultBranch = "develop";
    };
  };

  home.packages = [ pkgs.gh ];
}
