{ pkgs, ... }:
let
  claude-code-log = pkgs.python3Packages.callPackage ./claude-code-log.nix { };
in
{
  home.packages = [
    claude-code-log
  ];

  programs.claude-code.enable = true;

  home.file.".claude/CLAUDE.md".source = ./claude.md;
}
