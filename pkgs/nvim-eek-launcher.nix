# Launcher for the nvim-eek config: points Neovim at the config directory
# named by `appName` and provides the runtime dependencies the config expects:
# git for `vim.pack`, ripgrep for pickers, a C compiler for nvim-treesitter
# parser builds, plus the LSP servers and formatters wired up in
# 'plugin/40_plugins.lua' (zk powers the zk-nvim plugin).
{
  lib,
  stdenv,
  writeShellApplication,
  neovim,
  nvim ? neovim,
  gitMinimal,
  ripgrep,
  lua-language-server,
  nil,
  pyright,
  prettierd,
  prettier,
  google-java-format,
  stylua,
  nixfmt,
  black,
  rustfmt,
  vscode-json-languageserver,
  zk,
  appName ? "nvim",
  withCompiler ? true,
}:

writeShellApplication {
  name = appName;
  runtimeInputs = [
    nvim
    gitMinimal
    ripgrep
    lua-language-server
    nil
    pyright
    prettierd
    prettier
    google-java-format
    stylua
    nixfmt
    black
    rustfmt
    vscode-json-languageserver
    zk
  ]
  ++ lib.optionals withCompiler [ stdenv.cc ];
  text = ''
    export NVIM_APPNAME="''${NVIM_APPNAME:-${lib.escapeShellArg appName}}"

    exec nvim "$@"
  '';
}
