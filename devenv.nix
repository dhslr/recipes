{ pkgs, ... }:

{
  languages.elixir.enable = true;
  dotenv.enable = true;
  services.postgres = {
    enable = true;
    initialScript = ''
      CREATE ROLE postgres WITH CREATEDB LOGIN PASSWORD 'postgres';
    '';
  };
  dotenv.disableHint = true;
}
