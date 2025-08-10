local vue_language_server_path = "C:/Users/JSpedding/AppData/Roaming/npm/node_modules/@vue/"
local vue_plugin = {
	name = '@vue/typescript-plugin',
	location = vue_language_server_path,
	languages = { 'vue' },
	configNamespace = 'typescript',
}
return {
	cmd = { 'npx', 'vtsls', '--stdio' },
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
