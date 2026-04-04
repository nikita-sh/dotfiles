{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    bitwise # cli tool for bit / hex manipulation
    file # Show file information
    fzf # fuzzy finder
    lazygit
    nix-prefetch-github
    ripgrep # grep replacement
    ffmpeg
    ncdu # disk space
    openssl
    unzip
    wget
    nmap
    neofetch
    pstree
    qemu
    starfetch
    screen
    jq
    vim # just in case
    probe-rs-tools
    inetutils
    dnsutils
    pstree
    strace
    patchelf
    fd
    gh
    mosh
    buf
    nil
  ];
}
