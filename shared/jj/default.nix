{ ... }:
{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Nikita Shumeiko";
        email = "dev@nikitashko.com";
      };

      "--scope" = [
        {
          "--when".repositories = [ "~/dev/mercury/" ];
          user.email = "nikita@mercury.com";
        }
      ];
    };
  };
}
