{
  description = "A development environment to code typescript in neovim";

  inputs = {
    nvim-vimrc-code.url = "github:argent0/flake-nvim-vimrc-code";
  };

  outputs = { self, nixpkgs, nvim-vimrc-code }: 
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {

    packages.x86_64-linux.default = pkgs.stdenv.mkDerivation {
      name = "nvim-typescript";
      src = ./.;
      buildInputs = with pkgs; [
        nvim-vimrc-code.packages.x86_64-linux.default
      ];
      installPhase = ''
        mkdir -p $out/etc/nvim
        cat \
          ${nvim-vimrc-code.packages.x86_64-linux.default.outPath}/etc/nvim/vimrc \
          ${./lua-start} \
          ${./treesitter.lua} \
          ${./lspconfig.lua} \
          ${./lua-end}  > $out/etc/nvim/vimrc
      '';
    };

    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = let
        vimrcPath = "${self.packages.x86_64-linux.default}/etc/nvim/vimrc";
        local-neovim = pkgs.neovim.override {
          configure = {
              # Additional plugins to be installed
              packages.myVimPackages = with pkgs.vimPlugins; {
                start = [
                  vim-nix
                  copilot-vim
                  vim-surround
                  nvim-lspconfig
                  nvim-cmp
                  cmp-nvim-lsp
                  (nvim-treesitter.withPlugins (p: with p; [ typescript ]))
                ];
                opt = [ ];
              };
              customRC = builtins.readFile vimrcPath;
            };
          };
      in [
        pkgs.nodePackages.typescript
        pkgs.nodePackages.typescript-language-server
        pkgs.nodejs
        local-neovim
      ];
    };
  };
}
