vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1
-- vim.g.netrw_banner          = false
-- vim.g.netrw_treedepthstring = "│ "
-- vim.g.netrw_preview         = 1
-- vim.g.netrw_liststyle       = 3
-- vim.g.netrw_winsize         = 30
vim.g.mapleader          = " "
vim.g.maplocalleader     = "\\"
vim.opt.undofile         = true
vim.opt.termguicolors    = true
-- vim.opt.relativenumber   = true
vim.opt.number           = true
vim.opt.cursorline       = true
vim.opt.scrolloff        = 10
vim.opt.tabstop          = 4
vim.opt.shiftwidth       = 4
vim.opt.autoindent       = true
vim.opt.autochdir        = false
vim.opt.wrap             = false
vim.opt.winborder        = "rounded"

local servers            = {
	"luals",
	"ty",
	"rust_analyzer",
	"tinymist",
	"wgsl_analyzer",
	"vue_ls",
	"vtsls",
	-- "ts_ls",
	"eslint",
	-- "roslyn_ls"
}
for _, server in ipairs(servers) do
	vim.lsp.enable(server)
end
vim.diagnostic.config({
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = '',
			[vim.diagnostic.severity.WARN] = '',
			[vim.diagnostic.severity.HINT] = '',
			[vim.diagnostic.severity.INFO] = '',
		},
	},
	-- virtual_lines = {
	-- 	current_line = true
	-- }
})
function Diagnostic_count(bufnr)
	local diag_count = vim.diagnostic.count(bufnr)
	local highlights = {
		[vim.diagnostic.severity.ERROR] = 'DiagnosticError',
		[vim.diagnostic.severity.WARN] = 'DiagnosticWarn',
		[vim.diagnostic.severity.HINT] = 'DiagnosticHint',
		[vim.diagnostic.severity.INFO] = 'DiagnosticInfo',
	}

	local return_str = ""
	for sev, count in pairs(diag_count) do
		return_str = return_str
			.. "%#"
			.. highlights[sev]
			.. "#"
			.. vim.diagnostic.config().signs.text[sev]
			.. "%* : "
			.. count
			.. " "
	end
	return return_str
end

vim.o.statusline =
"%<%f %h%w%m%r %{%v:lua.Diagnostic_count(0)%}%= %{% &showcmdloc == 'statusline' ? '' : '' %}%{% exists('b:keymap_name') ? b:keymap_name : '' %}%{% &ruler ? ( &rulerformat == '' ? '%-14.(%l,%c%V%) %P' : &rulerformat ) : '' %}"
-- vim.o.statusline =
-- "%<%f %h%w%m%r %=%{% &showcmdloc == 'statusline' ? '%-10.S ' : '' %}%{% exists('b:keymap_name') ? '<'..b:keymap_name..'> ' : '' %}%{% &ruler ? ( &rulerformat == '' ? '%-14.(%l,%c%V%) %P' : &rulerformat ) : '' %}"
vim.api.nvim_create_autocmd('DiagnosticChanged', {
	callback = function(args)
		vim.cmd('redrawstatus')
	end,
})

-- vim.cmd [[set completeopt+=menuone,noinsert,popup,preinsert,fuzzy]]
-- vim.opt.completeopt = { "menuone", "noinsert", "popup", "preinsert", "fuzzy" }
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('my.lsp', {}),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		-- if client:supports_method('textDocument/implementation') then
		--   -- Create a keymap for vim.lsp.buf.implementation ...
		-- end
		-- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
		if client:supports_method('textDocument/inlayHint') then
			vim.lsp.inlay_hint.enable()
		end
		if client and client:supports_method 'textDocument/codeLens' then
			vim.lsp.codelens.refresh()
			vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
				buffer = bufnr,
				callback = vim.lsp.codelens.refresh,
			})
		end
		-- if client:supports_method('textDocument/completion') then
		-- 	-- Optional: trigger autocompletion on EVERY keypress. May be slow!
		-- 	local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
		-- 	client.server_capabilities.completionProvider.triggerCharacters = chars
		-- 	vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		-- end
		-- Auto-format ("lint") on save.
		-- Usually not needed if server supports "textDocument/willSaveWaitUntil".
		if not client:supports_method('textDocument/willSaveWaitUntil')
			and client:supports_method('textDocument/formatting')
			and client.name ~= 'vue_ls'
			or client.name == "eslint"
		then
			vim.api.nvim_create_autocmd('BufWritePre', {
				group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
				buffer = args.buf,
				callback = function()
					if client.name == "eslint" then
						vim.cmd "LspEslintFixAll"
					else
						vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
					end
				end,
			})
		end
	end,
})
---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
local progress = vim.defaulttable()
vim.api.nvim_create_autocmd("LspProgress", {
	---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		local value = ev.data.params
			.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
		if not client or type(value) ~= "table" then
			return
		end
		local p = progress[client.id]

		for i = 1, #p + 1 do
			if i == #p + 1 or p[i].token == ev.data.params.token then
				p[i] = {
					token = ev.data.params.token,
					msg = ("[%3d%%] %s%s"):format(
						value.kind == "end" and 100 or value.percentage or 100,
						value.title or "",
						value.message and (" **%s**"):format(value.message) or ""
					),
					done = value.kind == "end",
				}
				break
			end
		end

		local msg = {} ---@type string[]
		progress[client.id] = vim.tbl_filter(function(v)
			return table.insert(msg, v.msg) or not v.done
		end, p)

		local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
		-- vim.notify(table.concat(msg, "\n"), "info", {
		vim.notify(msg[#msg], "info", {
			id = "lsp_progress",
			title = client.name,
			opts = function(notif)
				notif.icon = #progress[client.id] == 0 and " "
					or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
			end,
		})
	end,
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out,                            "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)


require("lazy").setup({
	spec = {
		{
			"folke/tokyonight.nvim",
			lazy = false,
			priority = 1000,
			config = function()
				local transparent_highlights = {
					"SnacksNotifierBorderHint",
					"SnacksNotifierBorderInfo",
					"SnacksNotifierBorderWarn",
					"SnacksNotifierBorderError",
					"SnacksNotifierBorderDebug",
					"SnacksNotifierBorderTrace",
					"SnacksNotifierHint",
					"SnacksNotifierInfo",
					"SnacksNotifierWarn",
					"SnacksNotifierError",
					"SnacksPickerInputBorder",
					"SnacksPickerBoxTitle",
					"SnacksPickerInputTitle",
					"FloatBorder",
					"FloatTitle",
					"DiagnosticLineHighlightHint",
					"DiagnosticLineHighlightInfo",
					"DiagnosticLineHighlightWarn",
					"DiagnosticLineHighlightError",
					"DiagnosticVirtualTextHint",
					"DiagnosticVirtualTextInfo",
					"DiagnosticVirtualTextWarn",
					"DiagnosticVirtualTextError",
					"TreesitterContext",
					"NormalFloatBorder",
					"NormalFloat",
					"BufferTabpageFill",
					"EndOfBuffer",
					"SignColumn",
					"NormalNC",
					"Normal",
				}
				vim.cmd.colorscheme('tokyonight')
				for _, highlight in pairs(transparent_highlights) do
					vim.api.nvim_set_hl(0, highlight, { guibg = nil })
				end
				vim.api.nvim_set_hl(0, "DiagnosticLineHighlightError", { bg = "#C53B53" })
				vim.api.nvim_set_hl(0, "DiagnosticLineHighlightWarn", { bg = "#FFC777" })
				vim.api.nvim_set_hl(0, "DiagnosticLineHighlightInfo", { bg = "#0DB9D7" })
				vim.api.nvim_set_hl(0, "DiagnosticLineHighlightHint", { bg = "#4FD68E" })
			end
		},

		{
			"nvim-treesitter/nvim-treesitter",
			config = function()
				require("nvim-treesitter.configs").setup({
					auto_install = true,
					highlight = {
						enable = true
					}
				})
			end
		},

		{
			'neovim/nvim-lspconfig'
		},

		{
			'echasnovski/mini.nvim',
			version = '*',
			-- keys = { "gS" },
			config = function()
				require("mini.ai").setup()
				require('mini.splitjoin').setup()
				require('mini.surround').setup({
					respect_selection_type = true,
				})
				require('mini.bracketed').setup()
				require('mini.comment').setup()
				require('mini.icons').setup()
				require('mini.diff').setup({
					view = {
						style = 'sign',
						signs = { add = '▌', change = '▌', delete = '▌' },
					}
				})
				vim.api.nvim_set_hl(0, 'MiniDiffSignChange', { link = 'DiagnosticWarn' })
				vim.api.nvim_set_hl(0, 'MiniDiffSignAdd', { link = 'DiagnosticHint' })
				vim.api.nvim_set_hl(0, 'MiniDiffSignDelete', { link = 'DiagnosticError' })
				require('mini.pairs').setup({
					mappings = {
						['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\].' },
						['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\].' },
						['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].' },
						['<'] = { action = 'open', pair = '<>', neigh_pattern = '[\r%s>].', register = { cr = false } },

						[')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
						[']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },
						['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },
						['>'] = { action = 'close', pair = '<>', register = { cr = false } },

						['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[^\\].', register = { cr = false } },
						["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[^%a\\].', register = { cr = false } },
						['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^\\].', register = { cr = false } },
					},
				})
			end
		},

		{
			"folke/snacks.nvim",
			priority = 1000,
			lazy = false,
			---@type snacks.Config
			opts = {
				-- bigfile = { enabled = true },
				dashboard = { enabled = true },
				explorer = { enabled = true },
				indent = { enabled = true },
				input = { enabled = true },
				notifier = {
					enabled = true,
					timeout = 3000,
				},
				picker = {
					enabled = true,
					focus = 'list'
				},
				-- quickfile = { enabled = true },
				scope = { enabled = true },
				statuscolumn = { enabled = true },
				-- words = { enabled = true },
				styles = {
					notification = {
						-- wo = { wrap = true } -- Wrap notifications
					}
				}
			},
			keys = {
				-- Top Pickers & Explorer
				{ "<leader><space>", function() Snacks.picker.smart() end,                                   desc = "Smart Find Files" },
				{ "<leader>,",       function() Snacks.picker.buffers() end,                                 desc = "Buffers" },
				{ "<leader>/",       function() Snacks.picker.grep() end,                                    desc = "Grep" },
				{ "<leader>:",       function() Snacks.picker.command_history() end,                         desc = "Command History" },
				{ "<leader>n",       function() Snacks.picker.notifications() end,                           desc = "Notification History" },
				{ "<leader>e",       function() Snacks.explorer() end,                                       desc = "File Explorer" },
				-- find
				{ "<leader>fb",      function() Snacks.picker.buffers() end,                                 desc = "Buffers" },
				{ "<leader>fc",      function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
				{ "<leader>ff",      function() Snacks.picker.files() end,                                   desc = "Find Files" },
				{ "<leader>fg",      function() Snacks.picker.git_files() end,                               desc = "Find Git Files" },
				{ "<leader>fp",      function() Snacks.picker.projects() end,                                desc = "Projects" },
				{ "<leader>fr",      function() Snacks.picker.recent() end,                                  desc = "Recent" },
				-- git
				{ "<leader>gb",      function() Snacks.picker.git_branches() end,                            desc = "Git Branches" },
				{ "<leader>gu",      function() CustomPickers.git_diff_upstream("Develop") end,              desc = "Git Files Diff from Develop" },
				{
					"<leader>gU",
					function()
						vim.ui.input({ prompt = 'Enter Branch to diff with: ' },
							function(input) CustomPickers.git_diff_upstream(input) end)
					end,
					desc = "Git Files Diff from Develop"
				},
				{ "<leader>gl", function() Snacks.picker.git_log() end,               desc = "Git Log" },
				{ "<leader>gL", function() Snacks.picker.git_log_line() end,          desc = "Git Log Line" },
				{ "<leader>gs", function() Snacks.picker.git_status() end,            desc = "Git Status" },
				{ "<leader>gS", function() Snacks.picker.git_stash() end,             desc = "Git Stash" },
				{ "<leader>gd", function() Snacks.picker.git_diff() end,              desc = "Git Diff (Hunks)" },
				{ "<leader>gf", function() Snacks.picker.git_log_file() end,          desc = "Git Log File" },
				-- Grep
				{ "<leader>sb", function() Snacks.picker.lines() end,                 desc = "Buffer Lines" },
				{ "<leader>sB", function() Snacks.picker.grep_buffers() end,          desc = "Grep Open Buffers" },
				{ "<leader>sg", function() Snacks.picker.grep() end,                  desc = "Grep" },
				{ "<leader>sw", function() Snacks.picker.grep_word() end,             desc = "Visual selection or word", mode = { "n", "x" } },
				-- search
				{ '<leader>s"', function() Snacks.picker.registers() end,             desc = "Registers" },
				{ '<leader>s/', function() Snacks.picker.search_history() end,        desc = "Search History" },
				{ "<leader>sa", function() Snacks.picker.autocmds() end,              desc = "Autocmds" },
				{ "<leader>sb", function() Snacks.picker.lines() end,                 desc = "Buffer Lines" },
				{ "<leader>sc", function() Snacks.picker.command_history() end,       desc = "Command History" },
				{ "<leader>sC", function() Snacks.picker.commands() end,              desc = "Commands" },
				{ "<leader>sd", function() Snacks.picker.diagnostics() end,           desc = "Diagnostics" },
				{ "<leader>sD", function() Snacks.picker.diagnostics_buffer() end,    desc = "Buffer Diagnostics" },
				{ "<leader>sh", function() Snacks.picker.help() end,                  desc = "Help Pages" },
				{ "<leader>sH", function() Snacks.picker.highlights() end,            desc = "Highlights" },
				{ "<leader>si", function() Snacks.picker.icons() end,                 desc = "Icons" },
				{ "<leader>sj", function() Snacks.picker.jumps() end,                 desc = "Jumps" },
				{ "<leader>sk", function() Snacks.picker.keymaps() end,               desc = "Keymaps" },
				{ "<leader>sl", function() Snacks.picker.loclist() end,               desc = "Location List" },
				{ "<leader>sm", function() Snacks.picker.marks() end,                 desc = "Marks" },
				{ "<leader>sM", function() Snacks.picker.man() end,                   desc = "Man Pages" },
				{ "<leader>sp", function() Snacks.picker.lazy() end,                  desc = "Search for Plugin Spec" },
				{ "<leader>sq", function() Snacks.picker.qflist() end,                desc = "Quickfix List" },
				{ "<leader>sR", function() Snacks.picker.resume() end,                desc = "Resume" },
				{ "<leader>su", function() Snacks.picker.undo() end,                  desc = "Undo History" },
				{ "<leader>uC", function() Snacks.picker.colorschemes() end,          desc = "Colorschemes" },
				-- LSP
				{ "gd",         function() Snacks.picker.lsp_definitions() end,       desc = "Goto Definition" },
				{ "gD",         function() Snacks.picker.lsp_declarations() end,      desc = "Goto Declaration" },
				{ "grr",        function() Snacks.picker.lsp_references() end,        nowait = true,                     desc = "References" },
				{ "gri",        function() Snacks.picker.lsp_implementations() end,   desc = "Goto Implementation" },
				{ "gry",        function() Snacks.picker.lsp_type_definitions() end,  desc = "Goto T[y]pe Definition" },
				{ "<leader>ss", function() Snacks.picker.lsp_symbols() end,           desc = "LSP Symbols" },
				{ "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
				-- Other
				{ "<leader>z",  function() Snacks.zen() end,                          desc = "Toggle Zen Mode" },
				{ "<leader>Z",  function() Snacks.zen.zoom() end,                     desc = "Toggle Zoom" },
				{ "<leader>.",  function() Snacks.scratch() end,                      desc = "Toggle Scratch Buffer" },
				{ "<leader>S",  function() Snacks.scratch.select() end,               desc = "Select Scratch Buffer" },
				{ "<leader>n",  function() Snacks.notifier.show_history() end,        desc = "Notification History" },
				{ "<leader>bd", function() Snacks.bufdelete() end,                    desc = "Delete Buffer" },
				{ "<leader>cR", function() Snacks.rename.rename_file() end,           desc = "Rename File" },
				{ "<leader>gB", function() Snacks.gitbrowse() end,                    desc = "Git Browse",               mode = { "n", "v" } },
				{ "<leader>gg", function() Snacks.lazygit() end,                      desc = "Lazygit" },
				{ "<leader>un", function() Snacks.notifier.hide() end,                desc = "Dismiss All Notifications" },
				{ "<c-/>",      function() Snacks.terminal() end,                     desc = "Toggle Terminal" },
				{ "<c-_>",      function() Snacks.terminal() end,                     desc = "which_key_ignore" },
				-- { "]]",              function() Snacks.words.jump(vim.v.count1) end,                         desc = "Next Reference",           mode = { "n", "t" } },
				-- { "[[",              function() Snacks.words.jump(-vim.v.count1) end,                        desc = "Prev Reference",           mode = { "n", "t" } },
				{
					"<leader>N",
					desc = "Neovim News",
					function()
						Snacks.win({
							file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
							width = 0.6,
							height = 0.6,
							wo = {
								spell = false,
								wrap = false,
								signcolumn = "yes",
								statuscolumn = " ",
								conceallevel = 3,
							},
						})
					end,
				}
			},
			init = function()
				vim.api.nvim_create_autocmd("User", {
					pattern = "VeryLazy",
					callback = function()
						-- Setup some globals for debugging (lazy-loaded)
						_G.dd = function(...)
							Snacks.debug.inspect(...)
						end
						_G.bt = function()
							Snacks.debug.backtrace()
						end
						vim.print = _G.dd -- Override print to use snacks for `:=` command

						-- Create some toggle mappings
						Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
						Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
						Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
						Snacks.toggle.diagnostics():map("<leader>ud")
						Snacks.toggle.line_number():map("<leader>ul")
						Snacks.toggle.option("conceallevel",
							{ off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
						Snacks.toggle.treesitter():map("<leader>uT")
						Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map(
							"<leader>ub")
						Snacks.toggle.inlay_hints():map("<leader>uh")
						Snacks.toggle.indent():map("<leader>ug")
						Snacks.toggle.dim():map("<leader>uD")
					end,
				})
			end,
		},

		{
			"folke/which-key.nvim",
			event = "VeryLazy",
			opts = {
				spec = {
					{ "<leader>gn", "/\\(<\\|=\\|>\\)\\{3,}.*<cr>", desc = "Next Merge Conflict Marker" }
					-- ===
					-- <<<
					-- >>>
				}
			}
		},

		{
			"rachartier/tiny-inline-diagnostic.nvim",
			-- event = "VeryLazy", -- Or `LspAttach`
			priority = 1000, -- needs to be loaded in first
			config = function()
				require('tiny-inline-diagnostic').setup()
				vim.diagnostic.config({ virtual_text = false }) -- Only if needed in your configuration, if you already have native LSP diagnostics
			end
		},

		{
			'saghen/blink.cmp',
			-- optional: provides snippets for the snippet source
			dependencies = { 'rafamadriz/friendly-snippets' },
			build = 'cargo build --release',
			---@module 'blink.cmp'
			---@type blink.cmp.Config
			opts = {
				keymap = { preset = 'default' },
				completion = { documentation = { auto_show = true } },
				sources = {
					default = { 'lsp', 'path', 'snippets', 'buffer' },
				},
				fuzzy = { implementation = "prefer_rust" }
			},
			opts_extend = { "sources.default" }
		},
		{
			'MeanderingProgrammer/render-markdown.nvim',
			dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
			-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
			-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
			---@module 'render-markdown'
			---@type render.md.UserConfig
			opts = {
				heading = {
					backgrounds = {},
				},
				completions = { blink = { enabled = true } },
			},
		},
		{
			'AntonVanAssche/md-headers.nvim',
			dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
			version = '*',
			opts = {},
			ft = { 'markdown' }, -- Load only for markdown files.
		}


		-- {
		-- 	'saghen/blink.pairs',
		-- 	version = '*', -- (recommended) only required with prebuilt binaries
		--
		-- 	build = 'cargo build --release',
		--
		-- 	--- @module 'blink.pairs'
		-- 	--- @type blink.pairs.Config
		-- 	opts = {
		-- 		mappings = {
		-- 			-- you can call require("blink.pairs.mappings").enable() and require("blink.pairs.mappings").disable() to enable/disable mappings at runtime
		-- 			enabled = true,
		-- 			-- see the defaults: https://github.com/Saghen/blink.pairs/blob/main/lua/blink/pairs/config/mappings.lua#L10
		-- 			pairs = {},
		-- 		},
		-- 		highlights = {
		-- 			enabled = true,
		-- 			groups = {
		-- 				'BlinkPairsOrange',
		-- 				'BlinkPairsPurple',
		-- 				'BlinkPairsBlue',
		-- 			},
		-- 			matchparen = {
		-- 				enabled = true,
		-- 				group = 'MatchParen',
		-- 			},
		-- 		},
		-- 		debug = false,
		-- 	}
		-- },

		-- {
		-- 	"seblyng/roslyn.nvim",
		-- 	ft = "cs",
		-- 	---@module 'roslyn.config'
		-- 	---@type RoslynNvimConfig
		-- 	opts = {
		-- 		-- your configuration comes here; leave empty for default settings
		-- 		broad_search = true,
		-- 		lock_target = true
		-- 	},
		-- },
		{
			"kndndrj/nvim-dbee",
			dependencies = {
				"MunifTanjim/nui.nvim",
			},
			build = function()
				-- Install tries to automatically detect the install method.
				-- if it fails, try calling it with one of these parameters:
				--    "curl", "wget", "bitsadmin", "go"
				require("dbee").install("go")
			end,
			config = function()
				require("dbee").setup( --[[optional config]])
			end,
		},
	},

	checker = { enabled = true },
})

local function pick_cmd_result(picker_opts)
	local git_root = Snacks.git.get_root()
	local function finder(opts, ctx)
		return require("snacks.picker.source.proc").proc({
			opts,
			{
				cmd = picker_opts.cmd,
				args = picker_opts.args,
				transform = function(item)
					item.cwd = picker_opts.cwd or git_root
					item.file = item.text
				end,
			},
		}, ctx)
	end

	Snacks.picker.pick {
		source = picker_opts.name,
		finder = finder,
		preview = picker_opts.preview,
		title = picker_opts.title,
	}
end
CustomPickers = {}
function CustomPickers.git_diff_upstream(upstream)
	pick_cmd_result {
		cmd = "git",
		args = { "diff", "--no-commit-id", "--name-only", "--diff-filter=d", upstream },
		name = "git_diff_upstream",
		title = "Git Branch Changed Files",
		preview = "file",
	}
end
