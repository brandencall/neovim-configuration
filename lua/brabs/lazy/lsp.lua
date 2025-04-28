return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },


    config = function()
        vim.api.nvim_create_autocmd("DiagnosticChanged", {
            callback = function()
                vim.diagnostic.setqflist({ open = false })
            end,
        })
        vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*",
            callback = function()
                vim.lsp.buf.code_action({
                    context = { only = { "source.organizeImports" } },
                    apply = true,
                })
            end,
            desc = "Auto-import missing packages before saving",
        })
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "omnisharp",
                "ts_ls",
                "pylsp",
            },
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,

                zls = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.zls.setup({
                        root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
                        settings = {
                            zls = {
                                enable_inlay_hints = true,
                                enable_snippets = true,
                                warn_style = true,
                            },
                        },
                    })
                    vim.g.zig_fmt_parse_errors = 0
                    vim.g.zig_fmt_autosave = 0
                end,
                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,
                ["omnisharp"] = function()
                    require("lspconfig").omnisharp.setup({
                        capabilities = capabilities,
                        cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
                        enable_roslyn_analyzers = true,    -- Enable extra C# code analysis
                        organize_imports_on_format = true, -- Auto-organize imports
                        enable_import_completion = true,   -- Suggest missing imports
                        settings = {
                            FormattingOptions = {
                                EnableEditorConfigSupport = true
                            }
                        }
                    })
                end,
                ["ts_ls"] = function()
                    require("lspconfig").ts_ls.setup({
                        capabilities = capabilities,
                        settings = {
                            typescript = {
                                inlayHints = {
                                    includeInlayParameterNameHints = "all",
                                    includeInlayEnumMemberValueHints = true,
                                },
                            },
                        },
                        root_dir = require("lspconfig.util").root_pattern("package.json", "tsconfig.json",
                            "jsconfig.json", ".git"),
                    })
                end,
                ["pylsp"] = function()
                    require("lspconfig").pylsp.setup({
                        capabilities = capabilities,
                        settings = {
                            python = {
                                analysis = {
                                    autoSearchPaths = true,
                                    extraPaths = { "C:/Users/Brand/AppData/Local/Programs/Python/Python313/Lib/site-packages" },
                                    diagnosticMode = "workspace",
                                    useLibraryCodeForTypes = true,
                                },
                                pythonPath = "C:/Users/Brand/AppData/Local/Programs/Python/Python313"
                            },
                            pylsp = {
                                plugins = {
                                    pycodestyle = {
                                        enabled = true,
                                        maxLineLength = 120,
                                    }
                                }
                            },
                        },
                    })
                end,
                ["eslint"] = function()
                    require("lspconfig").eslint.setup({
                        capabilities = capabilities,
                    })
                end,
            }
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<CR>'] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = true,
                }),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
