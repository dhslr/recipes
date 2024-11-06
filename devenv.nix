{ pkgs, ... }:

{
  dotenv.enable = true;
  services.postgres = {
    enable = true;
    initialScript = ''
      CREATE ROLE postgres WITH CREATEDB LOGIN PASSWORD 'postgres';
    '';
  };
  dotenv.disableHint = true;
  packages = [
    pkgs.chromium
    pkgs.chromedriver
    pkgs.elixir
    pkgs.erlang
  ];
}
