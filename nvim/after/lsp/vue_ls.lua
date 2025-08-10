return {
	filetypes = { 'vue' },
	cmd = { 'npx', 'vue-language-server', '--stdio' },
	init_options = {
		typescript = {
			-- replace with your global TypeScript library path
			tsdk = "C:/Users/JSpedding/AppData/Roaming/npm/node_modules/typescript/lib"
		}
	},
	settings = {
		vue = {
			suggest = { componentNameCasing = "alwaysPascalCase" }
		}
	}
	-- before_init = function(params, config)
	--   local lib_path = vim.fs.find('node_modules/typescript/lib', { path = new_root_dir, upward = true })[1]
	--   if lib_path then
	--     config.init_options.typescript.tsdk = lib_path
	--   end
	-- end
}
