{ pkgs, ... }:

{
  languages.javascript.enable = true;
  languages.javascript.npm.enable = true;
  dotenv.enable = true;
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_15;
    initialScript = ''
      CREATE ROLE postgres WITH CREATEDB LOGIN PASSWORD 'postgres';
    '';
  };
  dotenv.disableHint = true;
  packages = [
    pkgs.chromedriver
    pkgs.elixir
    pkgs.erlang
  ];
}
