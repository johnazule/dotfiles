return {
	settings = {
		yaml = {
			schemaStore = {
				-- You must disable built-in schemaStore support if you want to use
				-- this plugin and its advanced options like `ignore`.
				enable = false,
				-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
				url = "",
			},
			schemas = require('schemastore').yaml.schemas {
				replace = {
					['bitbucket-pipelines'] = {
						description = 'Patched pipelines schema',
						name = 'bitbucket-pipelines',
						fileMatch = 'bitbucket-pipelines.yml',
						url = 'file:E:/bitbucket-pipelines.schema.json',
					}
				}
			},
		}
	}
}
