local vue_language_server_path = "C:/Users/JSpedding/AppData/Local/Volta/tools/shared/@vue/language-server"
local vue_plugin = {
	name = '@vue/typescript-plugin',
	location = vue_language_server_path,
	languages = { 'vue' },
	configNamespace = 'typescript',
}
return {
	cmd = { 'vtsls', '--stdio' },
	settings = {
		vtsls = {
			tsserver = {
				globalPlugins = {
					vue_plugin,
				},
			},
		},
	},
	--   init_options = {
	--     plugins = {
	--       vue_plugin,
	--     },
	--   },
	filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
}
