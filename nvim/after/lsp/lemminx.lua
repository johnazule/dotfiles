---@type vim.lsp.Config
return {
	cmd = { 'lemminx-win32' },
	filetypes = { 'xml', 'xsd', 'xsl', 'xslt', 'svg' },
	root_markers = { '.git' },
	settings = {
		xml = {
			format = {
				enabled = true,
				splitAttributes = true, -- Optional configuration rule
			},
		},
	},
}
