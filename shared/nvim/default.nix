{
  pkgs,
  ...
}:
{
  home = {
    packages = [
      pkgs.neovim
      pkgs.tree-sitter
    ];

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      FZF_DEFAULT_COMMAND = "fd --type f";
    };
  };

  xdg = {
    configFile.nvim.source = ./.;
  };
}
