# Idempotent plugin prefetch: installs the plugins pinned in
# 'nvim-pack-lock.json' into the data directory so the first interactive
# launch works offline. A stamp file records the config it prefetched for,
# so re-running is a no-op until the config package changes.
{
  lib,
  writeShellApplication,
  neovim,
  nvim ? neovim,
  git,
  nvim-eek-config,
  appName ? "nvim",
}:

writeShellApplication {
  name = "nvim-eek-install";
  runtimeInputs = [
    nvim
    git
  ];
  text = ''
    export NVIM_APPNAME=${lib.escapeShellArg appName}

    config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/$NVIM_APPNAME"
    data_dir="''${XDG_DATA_HOME:-$HOME/.local/share}/$NVIM_APPNAME"
    stamp_file="$data_dir/.nvim-eek-rev"
    pinned_rev=${lib.escapeShellArg "${nvim-eek-config}"}

    if [ -f "$stamp_file" ] && [ "$(cat "$stamp_file")" = "$pinned_rev" ]; then
      echo "nvim-eek-install: config (rev $pinned_rev) already installed"
      exit 0
    fi

    if [ ! -d "$config_dir" ]; then
      echo "nvim-eek-install: error: config not found at $config_dir" >&2
      echo "nvim-eek-install: install it with home-manager (programs.nvim-eek) or symlink it manually" >&2
      exit 1
    fi

    echo "nvim-eek-install: prefetching plugins pinned in nvim-pack-lock.json"

    # Install plugins: the config's own `vim.pack.add()` calls install during
    # startup (they block until each clone finishes); the explicit pass below
    # covers anything deferred by the config. All installs land at the
    # revisions pinned in the lockfile.
    nvim --headless \
      -c 'lua local lock_path = vim.fn.stdpath("config") .. "/nvim-pack-lock.json"; if vim.uv.fs_stat(lock_path) ~= nil then local lock = vim.json.decode(table.concat(vim.fn.readfile(lock_path), "\n")); local specs = {}; for _, p in pairs(lock.plugins) do specs[#specs + 1] = p.src end; vim.pack.add(specs, { load = false }) end' \
      -c 'lua vim.pack.update(nil, { target = "lockfile" })' \
      -c 'silent! write' -c 'qa!' \
      || echo "nvim-eek-install: warning: plugin prefetch failed; plugins will be installed on first launch"

    mkdir -p "$data_dir"
    printf '%s\n' "$pinned_rev" > "$stamp_file"
  '';
}
