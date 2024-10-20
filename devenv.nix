{ pkgs, ... }:

{
  languages.javascript.enable = true;
  languages.javascript.npm.enable = true;
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
