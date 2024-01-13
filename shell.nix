{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
   LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
   packages = with pkgs; [
     git
     nodejs
     elixir_1_15 
     gh
     postgresql
   ];
   shellHook = ''
     tmpdir=$(mktemp -d)
     initdb -D $tmpdir
     pg_ctl -D $tmpdir -l logfile -o "--unix_socket_directories='$PWD'" start
     createuser -h $(pwd) --createdb postgres
     createdb -h $(pwd) -U postgres recipes_dev
     psql -h $(pwd) -U postgres recipes_dev < ./priv/repo/seeds.sql
     trap 'pg_ctl -D $tmpdir -o "--unix_socket_directories=$PWD" stop' EXIT
   '';
} 
