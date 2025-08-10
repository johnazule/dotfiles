-- local base_on_attach = vim.lsp.config.eslint.on_attach
return {
	cmd = { 'npx', 'vscode-eslint-language-server', '--stdio' },
	--   on_attach = function(client, bufnr)
	--     if not base_on_attach then return end
	--
	--     base_on_attach(client, bufnr)
	--     vim.api.nvim_create_autocmd("BufWritePre", {
	--       buffer = bufnr,
	--       command = "LspEslintFixAll",
	--     })
	--   end,
	-- })

	settings = {
		codeActionOnSave = {
			enable = true
		}
		-- configFile = "E:/Development Projects/simon/Simon.Web/babel.config.json"
		-- workingDirectories = { mode = 'auto' },
		-- workingDirectory = { mode = 'location' },
		-- workingDirectory = { pattern = "E:/Development Projects/simon/Simon.Web" },
		-- workingDirectory = { "E:/Development Projects/simon/Simon.Web" },
	}
}
