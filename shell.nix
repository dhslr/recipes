{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
   LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
   packages = with pkgs; [
     nodejs
     elixir_1_15
   ];
}
