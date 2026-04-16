{ pkgs, ... }:
let
  claude-code-log = pkgs.python3Packages.callPackage ./claude-code-log.nix { };
  claude-code-patched = pkgs.claude-code.overrideAttrs (oldAttrs: rec {
    version = "2.1.111";
    src = pkgs.fetchzip {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
      hash = "sha256-K3qhZXVJ2DIKv7YL9f/CHkuUYnK0lkIR1wjEa+xeSCk=";
    };
  });
in
{
  home.packages = [
    claude-code-log
  ];

  programs.claude-code = {
    enable = true;
    package = claude-code-patched;
  };

  home.file.".claude/CLAUDE.md".source = ./claude.md;
}
