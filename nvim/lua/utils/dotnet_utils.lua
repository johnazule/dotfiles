local M = {}

---@param bufname string
---@return boolean
M.is_decompiled = function(bufname)
	local _, endpos = bufname:find('[/\\]MetadataAsSource[/\\]')
	if endpos == nil then
		return false
	end
	return vim.fn.finddir(bufname:sub(1, endpos), vim.uv.os_tmpdir()) ~= ''
end

---@param bufnr integer
---@return string
M.find_root = function(bufnr)
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	-- don't try to find sln or csproj for files from libraries
	-- outside of the project
	if not M.is_decompiled(bufname) then
		-- try find solutions root first
		local root_dir = vim.fs.root(bufnr, function(fname, _)
			return fname:match('%.sln[x]?$') ~= nil
		end)

		if not root_dir then
			-- try find projects root
			root_dir = vim.fs.root(bufnr, function(fname, _)
				return fname:match('%.csproj$') ~= nil
			end)
		end

		if root_dir then
			return root_dir
		end
	else
		-- Decompiled code (example: "/tmp/MetadataAsSource/f2bfba/DecompilationMetadataAsSourceFileProvider/d5782a/Console.cs")
		local prev_buf = vim.fn.bufnr('#')
		local client = vim.lsp.get_clients({
			name = 'roslyn_ls',
			bufnr = prev_buf ~= 1 and prev_buf or nil,
		})[1]
		if client then
			return client.config.root_dir
		end
	end
end

local client_id_to_solution = {}

---@param client_id integer
---@param solution? string
function M.set_solution_file(client_id, solution)
	client_id_to_solution[client_id] = solution
	vim.g.roslyn_nvim_selected_solution = solution
end

---@param client_id integer
function M.get_solution_file(client_id)
	return client_id_to_solution[client_id]
end

return M
