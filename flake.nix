# flake.nix
{
  description = "nvim-eek: a mini.nvim-based Neovim config, packaged with its dependencies";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system nixpkgs.legacyPackages.${system});

      packages = forAllSystems (
        system: pkgs:
        let
          nvim-eek-config = pkgs.callPackage ./pkgs/nvim-eek-config.nix { inherit self; };
        in
        {
          inherit nvim-eek-config;

          nvim-eek = pkgs.callPackage ./pkgs/nvim-eek-launcher.nix { };

          nvim-eek-install = pkgs.callPackage ./pkgs/nvim-eek-install.nix {
            inherit nvim-eek-config;
          };

          default = pkgs.callPackage ./pkgs/nvim-eek-launcher.nix { };
        }
      );

      checks = forAllSystems (
        system: pkgs: {
          # The launcher must put every runtime dependency of the config on
          # PATH: git for `vim.pack`, ripgrep for pickers, a C compiler for
          # tree-sitter parser builds, the LSP servers, formatters, and zk.
          nvim-eek-smoke = pkgs.runCommand "nvim-eek-smoke" { } ''
            ${packages.${system}.nvim-eek}/bin/nvim --headless --clean \
              -c 'lua io.stdout:write(vim.fn.executable("git") .. vim.fn.executable("rg") .. vim.fn.executable("cc") .. vim.fn.executable("lua-language-server") .. vim.fn.executable("nil") .. vim.fn.executable("pyright") .. vim.fn.executable("stylua") .. vim.fn.executable("nixfmt") .. vim.fn.executable("zk"))' \
              -c 'qa!' > "$out"
            test "$(cat "$out")" = "111111111"
          '';
        }
      );
    in
    {
      inherit packages checks;

      devShells = forAllSystems (
        system: pkgs: {
          default = pkgs.mkShell {
            packages = [
              packages.${system}.nvim-eek
              pkgs.stylua
              pkgs.nixfmt
            ];
          };
        }
      );

      homeManagerModules.default = import ./modules/home-manager.nix {
        nvimEekPackages = packages;
      };
    };
}
