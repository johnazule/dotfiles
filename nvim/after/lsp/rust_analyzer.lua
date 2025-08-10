vim.lsp.commands['rust-analyzer.gotoLocation'] = function(command, ctx)
	local client = vim.lsp.get_client_by_id(ctx.client_id)
	if client then
		vim.lsp.util.show_document(command.arguments[1], client.offset_encoding or 'utf-8')
	end
end

vim.lsp.commands['rust-analyzer.showReferences'] = function(_)
	vim.lsp.buf.implementation()
end

vim.lsp.commands['rust-analyzer.runSingle'] = function(command)
	local r = command.arguments[1]
	local cmd = { 'cargo', unpack(r.args.cargoArgs) }
	if r.args.executableArgs and #r.args.executableArgs > 0 then
		vim.list_extend(cmd, { '--', unpack(r.args.executableArgs) })
	end

	local proc = vim.system(cmd, { cwd = r.args.cwd })

	local result = proc:wait()

	if result.code == 0 then
		vim.notify(result.stdout, vim.log.levels.INFO)
	else
		vim.notify(result.stderr, vim.log.levels.ERROR)
	end
end
--- @type vim.lsp.ClientConfig
return {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	flags = { allow_incremental_sync = true, debounce_text_changes = 500, exit_timeout = false },
	capabilities = {
		textDocument = {
			completion = {
				completionItem = {
					resolveSupport = {
						properties = {
							"documentation",
							"detail",
							"additionalTextEdits"
						}
					}
				}
			}
		},
		experimental = {
			serverStatusNotification = true,
			hoverActions = true,
			codeActionGroup = true,
			commands = {
				commands = {
					'rust-analyzer.showReferences',
					-- 'rust-analyzer.debugSingle',
					'rust-analyzer.runSingle',
					'rust-analyzer.gotoLocation',
					'rust-analyzer.triggerParameterHints',
				}
			}
		}
	},
	settings = {
		['rust-analyzer'] = {
			cargo = {
				allFeatures = true,
				loadOutDirsFromCheck = true,
				runBuildScripts = true,
			},
			hover = {
				actions = {
					enable = true,
					references = {
						enable = true
					}
				}
			},
			imports = {
				preferPrelude = true
			},
			inlayHints = {
				genericParameterHints = {
					type = {
						enable = false
					}
				}
			},
			completion = {
				fullFunctionSignatures = {
					enable = false
				}
			},
			diagnostics = {
				enable = true,
				experimental = {
					enable = true
				},
				styleLints = {
					enable = true
				}
			},
			check = {
				command = "clippy",
			},
			procMacro = {
				enable = true
			},
			lens = {
				enable = true,
				run = {
					enable = true
				},
				implementations = {
					enable = true
				},
				references = {
					adt = {
						enable = true
					},
					method = {
						enable = true
					},
					trait = {
						enable = true
					},
					enumVariant = {
						enable = true
					}
				}
			},
		}
	}

}

-- -- Override the runSingle command on the client
-- vim.lsp.commands['rust-analyzer.runSingle'] = function(command)
--   local r = command.arguments[1]
--   local cmd = { 'cargo', unpack(r.args.cargoArgs) }
--   if r.args.executableArgs and #r.args.executableArgs > 0 then
--     vim.list_extend(cmd, { '--', unpack(r.args.executableArgs) })
--   end
--
--   local proc = vim.system(cmd, { cwd = r.args.cwd })
--
--   local result = proc:wait()
--
--   if result.code == 0 then
--     vim.notify(result.stdout, vim.log.levels.INFO)
--   else
--     vim.notify(result.stderr, vim.log.levels.ERROR)
--   end
-- end
-- return
--   --- @type vim.lsp.ClientConfig
--   {
--     cmd = { "rust-analyzer" },
--     filetypes = { "rust" },
--     capabilities = {
--       experimental = {
--         commands = {
--           commands = {
--             'rust-analyzer.showReferences',
--              'rust-analyzer.runSingle',
--              'rust-analyzer.debugSingle',
--           }
--         }
--       }
--     },
--     settings = {
--       ['rust-analyzer'] = {
--         lens = {
--           enable = true,
--           run = { enable = true },
--           implementations = { enable = true },
--           references = {
--             adt = { enable = true },
--             method = { enable = true},
--             trait = { enable = true },
--             enumVariant = { enable = true }
--           }
--         },
--       }
--     }
--   }
