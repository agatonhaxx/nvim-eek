# nvim-eek

A [mini.nvim](https://github.com/nvim-mini/mini.nvim)-based Neovim configuration, packaged as a Nix flake.

The config lives in this repository root (`init.lua`, `plugin/`, `after/`, `snippets/`). Plugins are managed by Neovim's built-in `vim.pack` package manager and pinned in `nvim-pack-lock.json`.

## Flake outputs

| Output | Description |
| --- | --- |
| `packages.<system>.nvim-eek-config` | Store copy of the config files Neovim reads |
| `packages.<system>.nvim-eek` | `nvim` launcher with all runtime dependencies on `PATH` |
| `packages.<system>.nvim-eek-install` | Activation-time prefetch of the pinned plugins |
| `homeManagerModules.default` | Home-manager module (`programs.nvim-eek`) |
| `devShells.<system>.default` | Shell with the `nvim` launcher, `stylua`, and `nixfmt` |

Runtime dependencies provided by the launcher (scoped to the nvim process, not the shell):

- `git` — `vim.pack` plugin manager
- `ripgrep` — `mini.pick` pickers
- a C compiler — `nvim-treesitter` parser builds
- LSP servers — `lua-language-server`, `nil`, `pyright`
- formatters — `prettierd`/`prettier`, `google-java-format`, `stylua`, `nixfmt`, `black`, `rustfmt`
- `zk` — the `zk-nvim` plugin

## Usage

### Home-manager

Add the flake as an input (after pushing this repo):

```nix
# flake.nix
inputs.nvim-eek = {
  url = "github:agatonhaxx/nvim-eek";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Then import the module and enable it:

```nix
# home.nix
{ inputs, ... }: {
  imports = [ inputs.nvim-eek.homeManagerModules.default ];
  programs.nvim-eek.enable = true;
}
```

By default the config is installed to `~/.config/nvim` and the launcher provides the plain `nvim` command. Note that home-manager symlinks the *entire* config directory, so `~/.config/nvim` must not contain unmanaged files. Set `programs.nvim-eek.appName` to use a separate config directory instead (the launcher command is then named after the appName).

At activation the pinned plugins are prefetched, so the first launch works offline. Don't enable `programs.neovim` or nixvim alongside it — both would provide a conflicting `nvim` binary.

### Standalone

```sh
nix run github:agatonhaxx/nvim-eek   # run the config
nix develop github:agatonhaxx/nvim-eek  # dev shell with nvim + stylua + nixfmt
```

## Updating plugins

The deployed config directory is a read-only store symlink, so `vim.pack` cannot write the lockfile there. Run the update from the repository itself, which is a writable copy of the config:

```sh
cd ~/dev/git/nvim-eek
env XDG_CONFIG_HOME=$PWD NVIM_APPNAME= nvim --headless \
  -c 'lua vim.pack.update()' -c 'write' -c 'qa!'
```

Plugins install into the same data directory the deployed config uses (`~/.local/share/nvim`), and the updated `nvim-pack-lock.json` lands in the repo — commit it so the flake keeps pinning the new revisions.

Every plugin added in the config must have a matching `nvim-pack-lock.json` entry; otherwise `vim.pack` tries to repair the lockfile at startup, which fails on the read-only config dir. The update command above regenerates the missing entries.
