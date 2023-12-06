{ ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      nuc-2 = {
        host = "nuc-2";
        hostname = "nuc-2";
        port = 22;
      };
      nuc-3 = {
        host = "nuc-3";
        hostname = "nuc-3";
        port = 22;
      };
      sagittarius = {
        host = "sagittarius";
        hostname = "sagittarius.vital-dk";
        port = 22;
        proxyCommand = "ssh nuc-3 -W %h:%p";
      };
      musca = {
        host = "musca";
        hostname = "musca.vital-dk";
        port = 22;
        proxyCommand = "ssh nuc-2 -W %h:%p";
      };
      pavo = {
        host = "pavo";
        hostname = "pavo.vital-dk";
        port = 22;
        proxyCommand = "ssh nuc-3 -W %h:%p";
      };
      perseus = {
        host = "perseus";
        hostname = "perseus.vital-dk";
        port = 22;
        proxyCommand = "ssh nuc-3 -W %h:%p";
      };
    };
    extraConfig = ''
      AddKeysToAgent yes
    '';
  };
}
