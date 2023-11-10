 let
   nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-23.05";
   pkgs = import nixpkgs { config = {}; overlays = []; };
 in

 pkgs.mkShell {
   packages = with pkgs; [
     git
     nodejs
     elixir_1_15 
     gh
     postgresql
   ];

   GIT_EDITOR = "${pkgs.neovim}/bin/nvim";

   shellHook = ''
    git status
   '';
 }
