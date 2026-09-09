# Store copy of the nvim-eek config: only the files Neovim actually reads.
# The home-manager module symlinks this into the config directory.
{ runCommand, self }:

runCommand "nvim-eek-config" { } ''
  mkdir -p "$out"
  cp -r ${self}/init.lua "$out/"
  cp -r ${self}/plugin "$out/"
  cp -r ${self}/after "$out/"
  cp -r ${self}/snippets "$out/"
  cp -r ${self}/nvim-pack-lock.json "$out/"
''
