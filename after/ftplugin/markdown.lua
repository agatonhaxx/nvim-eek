-- ┌─────────────────────────┐
-- │ Filetype config example │
-- └─────────────────────────┘
--
-- This is an example of a configuration that will apply only to a particular
-- filetype, which is the same as file's basename ('markdown' in this example;
-- which is for '*.md' files).
--
-- It can contain any code which will be usually executed when the file is opened
-- (strictly speaking, on every 'filetype' option value change to target value).
-- Usually it needs to define buffer/window local options and variables.
-- So instead of `vim.o` to set options, use `vim.bo` for buffer-local options and
-- `vim.cmd('setlocal ...')` for window-local options (currently more robust).
--
-- This is also a good place to set buffer-local 'mini.nvim' variables.
-- See `:h mini.nvim-buffer-local-config` and `:h mini.nvim-disabling-recipes`.

-- Enable spelling and wrap for window
vim.cmd("setlocal spell wrap")

-- Fold with tree-sitter
vim.cmd("setlocal foldmethod=expr foldexpr=v:lua.vim.treesitter.foldexpr()")

-- Disable built-in `gO` mapping in favor of 'mini.basics'
vim.keymap.del("n", "gO", { buffer = 0 })

-- Set markdown-specific surrounding in 'mini.surround'
vim.b.minisurround_config = {
	custom_surroundings = {
		-- Markdown link. Common usage:
		-- `saiwL` + [type/paste link] + <CR> - add link
		-- `sdL` - delete link
		-- `srLL` + [type/paste link] + <CR> - replace link
		L = {
			input = { "%[().-()%]%(.-%)" },
			output = function()
				local link = require("mini.surround").user_input("Link: ")
				return { left = "[", right = "](" .. link .. ")" }
			end,
		},
	},
}

-- zk-nvim: buffer-local mappings for a Zettelkasten notebook. Applied only
-- when the current buffer is inside a notebook root; the plugin is enabled
-- and globally mapped in 'plugin/40_plugins.lua'.
local ok, zk_util = pcall(require, "zk.util")
if ok and zk_util.notebook_root(vim.fn.expand("%:p")) ~= nil then
	local map = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = 0, desc = desc })
	end
	map("n", "<CR>", "<Cmd>lua vim.lsp.buf.definition()<CR>", "Follow link")
	map(
		"n",
		"<Leader>zn",
		"<Cmd>ZkNew { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>",
		"Create note here"
	)
	map("n", "<Leader>zb", "<Cmd>ZkBacklinks<CR>", "Backlinks")
	map("n", "<Leader>zl", "<Cmd>ZkLinks<CR>", "Links")
	map("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", "Hover")
	map("x", "<Leader>za", ":'<,'>lua vim.lsp.buf.range_code_action()<CR>", "Code action (selection)")
end
