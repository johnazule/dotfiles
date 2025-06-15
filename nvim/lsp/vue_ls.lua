return {
	cmd = { 'vue-language-server', '--stdio' },
	filetypes = { 'vue' },
	root_markers = { 'package.json' },
	init_options = {
		typescript = {
			-- replace with your global TypeScript library path
			tsdk = '/usr/local/lib/node_modules/typescript/lib'
		}
	},
	before_init = function(params, config)
		local lib_path = vim.fs.find('node_modules/typescript/lib', { path = new_root_dir, upward = true })[1]
		if lib_path then
			config.init_options.typescript.tsdk = lib_path
		end
	end
}
