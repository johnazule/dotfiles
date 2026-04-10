local uv = vim.uv
local fs = vim.fs
local dotnet_utils = require('utils.dotnet_utils')


---@param client vim.lsp.Client
---@param target string
local function on_init_sln(client, target)
	vim.notify('Initializing: ' .. vim.fn.fnamemodify(target, ":t"), vim.log.levels.TRACE, { title = 'roslyn_ls' })

	dotnet_utils.set_solution_file(client.id, target)

	local solution_uri = vim.uri_from_fname(vim.fn.fnamemodify(target, ":p"))

	---@diagnostic disable-next-line: param-type-mismatch
	client:notify('solution/open', {
		solution = solution_uri,
	})
end

---@param client vim.lsp.Client
---@param project_files string[]
local function on_init_project(client, project_files)
	vim.notify('Initializing: projects', vim.log.levels.TRACE, { title = 'roslyn_ls' })
	---@diagnostic disable-next-line: param-type-mismatch
	client:notify('project/open', {
		projects = vim.tbl_map(function(file)
			return vim.uri_from_fname(file)
		end, project_files),
	})
end

---@type vim.lsp.Config
return {
	cmd = {
		-- 'dotnet',
		-- 'C:\\Program Files\\roslyn_ls\\Microsoft.CodeAnalysis.LanguageServer.dll',
		'roslyn-language-server',
		'--logLevel',
		'Trace',
		'--extensionLogDirectory',
		-- fs.joinpath(uv.os_tmpdir(), 'roslyn_ls/logs'),
		fs.joinpath(vim.loop.cwd(), 'roslyn_ls/logs'),
		'--stdio',
		'--autoLoadProjects',
	},
	cmd_cwd = 'C:\\Program Files\\dotnet',

	handlers = {
		['window/_roslyn_showToast'] = function(_, result, ctx)
			vim.notify(result.message, vim.log.levels.INFO, { title = 'roslyn_ls: ' })

			return vim.NIL
		end,
	},

	root_dir = function(bufnr, cb)
		if cb ~= nil then
			cb(dotnet_utils.find_root(bufnr))
		end
	end,
	on_init = {
		function(client)
			local root_dir = client.config.root_dir
			local current_dir = vim.fn.getcwd()

			-- Change the current working directory
			vim.api.nvim_set_current_dir(root_dir)

			local solution_files = vim.fn.systemlist("rg --files -g '*.{sln,slnx,slnf}'")

			vim.api.nvim_set_current_dir(current_dir)

			-- if only one solution file found, then default to it
			if #solution_files == 1 then
				on_init_sln(client, solution_files[1])
				return
				-- if any solution files are found choose between them
			elseif #solution_files > 1 then
				vim.ui.select(solution_files, { prompt = 'Select Solution File: ' }, function(item, _idx)
					if item ~= nil then
						on_init_sln(client, item)
					end
				end)
				return
			end

			-- If no solution files found, load project files instead
			local project_files = vim.fn.systemlist("rg --files -g '*.csproj'")

			-- if only one project file found, then default to it
			if #project_files == 1 then
				on_init_project(client, project_files)
				return
				-- if any project files are found choose between them
			elseif #project_files > 1 then
				vim.ui.select(solution_files, { prompt = 'Select Solution File: ' }, function(item, _idx)
					if item ~= nil then
						on_init_project(client, { item })
					end
				end)
				return
			end
		end,
	},
}
