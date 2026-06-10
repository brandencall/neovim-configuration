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
                local diags = vim.diagnostic.get(nil)
                if #diags > 0 then
                    vim.diagnostic.setqflist({ open = false })
                end
            end,
        })
        vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = { "*.cs", "*.cpp", "*.c", "*.h", "*.hpp" },
            callback = function(args)
                local ft = vim.bo[args.buf].filetype

                if ft == "cs" or ft == "cpp" or ft == "c" then
                    vim.lsp.buf.code_action({
                        context = { only = { "source.organizeImports" } },
                        apply = true,
                    })
                end

                vim.lsp.buf.format({
                    bufnr = args.buf,
                    timeout_ms = 2000,
                })
            end,
            desc = "Organize imports + format on save",
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
                "clangd",
                "jdtls",
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
                        },
                    })
                end,
                ["clangd"] = function()
                    require("lspconfig").clangd.setup({
                        capabilities = capabilities, -- Reuse your existing capabilities
                        cmd = { "clangd", "--background-index", "--clang-tidy", "--compile-commands-dir=~/UnrealEngine" },
                        root_dir = function(fname)
                            local util = require('lspconfig.util')
                            -- Check for project root (e.g., .uproject or compile_commands.json)
                            local project_root = util.root_pattern('.uproject', 'compile_commands.json')(fname)
                            if project_root then
                                return project_root
                            end
                            -- Fallback to engine root
                            return '/home/brabs/UnrealEngine'
                        end,
                        settings = {
                            clangd = {
                                InlayHints = {
                                    Enabled = true, -- Show type hints in code (if supported by your clangd version)
                                },
                                Formatting = {
                                    Enable = true, -- Enable clang-format integration
                                    Style = "file",
                                },
                            },
                        },
                        init_options = {
                            usePlaceholders = true,
                            completeUnimported = true, -- Suggest missing includes
                            clangdFileStatus = true,
                            compilationDatabasePath = '/home/brabs/UnrealEngine',
                        },
                    })
                end,
                ["eslint"] = function()
                    require("lspconfig").eslint.setup({
                        capabilities = capabilities,
                    })
                end,
                vim.api.nvim_create_autocmd("FileType", {
                    pattern = "java",
                    callback = function()
                        require("brabs.java")
                    end,
                })
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
