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
		experiemental = {
			serverStatusNotification = true,
			hoverActions = true,
			codeActionGroup = true,
			commands = {
				commands = {
					'rust-analyzer.showReferences',
					'rust-analyzer.debugSingle',
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
