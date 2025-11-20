-- Java LSP Configuration for LazyVim
-- Uses nvim-jdtls for Java development
-- Requires: Mason to install jdtls, java-test, java-debug-adapter

return {
  {
    "mfussenegger/nvim-jdtls",
    dependencies = { "williamboman/mason.nvim" },
    ft = { "java" },
    opts = function()
      return {
        -- This will be used by LazyVim's jdtls integration
        -- We'll set up the full config in the config function
      }
    end,
    config = function()
      -- Defer the configuration until a Java file is actually opened
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
          local jdtls = require("jdtls")

          -- Use standard paths instead of Mason registry
          local jdtls_install = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
          local java_debug_install = vim.fn.stdpath("data") .. "/mason/packages/java-debug-adapter"
          local java_test_install = vim.fn.stdpath("data") .. "/mason/packages/java-test"

          -- Check if jdtls is installed
          if vim.fn.isdirectory(jdtls_install) == 0 then
            vim.notify("jdtls is not installed. Please run :MasonInstall jdtls", vim.log.levels.WARN)
            return
          end

          local lombok_jar = jdtls_install .. "/lombok.jar"

          -- Find the jdtls launcher jar
          local launcher_jar = vim.fn.glob(jdtls_install .. "/plugins/org.eclipse.equinox.launcher_*.jar")
          if launcher_jar == "" then
            vim.notify("jdtls launcher jar not found. Please reinstall jdtls via :Mason", vim.log.levels.ERROR)
            return
          end

          -- Platform-specific configuration directory
          local config_dir = jdtls_install .. "/config_mac"
          if vim.fn.has("linux") == 1 then
            config_dir = jdtls_install .. "/config_linux"
          elseif vim.fn.has("win32") == 1 then
            config_dir = jdtls_install .. "/config_win"
          end

          -- Workspace directory (project-specific)
          local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
          local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

          -- Get bundles for debugging and testing
          local bundles = {}

          -- Java debug adapter
          if vim.fn.isdirectory(java_debug_install) == 1 then
            vim.list_extend(bundles, vim.split(vim.fn.glob(java_debug_install .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"), "\n"))
          end

          -- Java test runner
          if vim.fn.isdirectory(java_test_install) == 1 then
            vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_install .. "/extension/server/*.jar"), "\n"))
          end

      local config = {
        cmd = {
          "java",
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.protocol=true",
          "-Dlog.level=WARNING",
          "-javaagent:" .. lombok_jar,
          "-Xms1g",
          "--add-modules=ALL-SYSTEM",
          "--add-opens", "java.base/java.util=ALL-UNNAMED",
          "--add-opens", "java.base/java.lang=ALL-UNNAMED",
          "-jar", launcher_jar,
          "-configuration", config_dir,
          "-data", workspace_dir,
        },

        root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),

        settings = {
          java = {
            eclipse = {
              downloadSources = true,
            },
            configuration = {
              updateBuildConfiguration = "interactive",
              runtimes = {
                {
                  name = "JavaSE-21",
                  path = vim.fn.trim(vim.fn.system("/usr/libexec/java_home -v 21")),
                  default = true,
                },
              },
            },
            maven = {
              downloadSources = true,
            },
            implementationsCodeLens = {
              enabled = true,
            },
            referencesCodeLens = {
              enabled = true,
            },
            references = {
              includeDecompiledSources = true,
            },
            format = {
              enabled = true,
            },
            signatureHelp = { enabled = true },
            contentProvider = { preferred = "fernflower" },
            completion = {
              favoriteStaticMembers = {
                "org.hamcrest.MatcherAssert.assertThat",
                "org.hamcrest.Matchers.*",
                "org.hamcrest.CoreMatchers.*",
                "org.junit.jupiter.api.Assertions.*",
                "java.util.Objects.requireNonNull",
                "java.util.Objects.requireNonNullElse",
                "org.mockito.Mockito.*",
              },
              importOrder = {
                "java",
                "javax",
                "com",
                "org",
              },
            },
            sources = {
              organizeImports = {
                starThreshold = 9999,
                staticStarThreshold = 9999,
              },
            },
            codeGeneration = {
              toString = {
                template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
              },
              useBlocks = true,
            },
          },
        },

        init_options = {
          bundles = bundles,
          extendedClientCapabilities = {
            progressReportProvider = false,
          },
        },

        capabilities = {
          workspace = {
            configuration = true,
          },
          textDocument = {
            completion = {
              completionItem = {
                snippetSupport = true,
              },
            },
          },
        },

        handlers = {
          ["language/status"] = function(_, result)
            -- Suppress status messages
          end,
          ["$/progress"] = function(_, result, ctx)
            -- Suppress progress messages
          end,
        },

        on_attach = function(client, bufnr)
          -- Setup DAP
          jdtls.setup_dap({ hotcodereplace = "auto" })

          -- Register handlers for jdtls commands
          local function buf_set_keymap(...)
            vim.api.nvim_buf_set_keymap(bufnr, ...)
          end
          local opts = { noremap = true, silent = true }

          -- Register Java commands
          vim.api.nvim_buf_create_user_command(bufnr, "JavaTestNearest", function()
            jdtls.test_nearest_method()
          end, { desc = "Test nearest method" })

          vim.api.nvim_buf_create_user_command(bufnr, "JavaTestClass", function()
            jdtls.test_class()
          end, { desc = "Test class" })

          vim.api.nvim_buf_create_user_command(bufnr, "JavaOrganizeImports", function()
            jdtls.organize_imports()
          end, { desc = "Organize imports" })

          vim.api.nvim_buf_create_user_command(bufnr, "JavaExtractVariable", function()
            jdtls.extract_variable()
          end, { desc = "Extract variable" })

          vim.api.nvim_buf_create_user_command(bufnr, "JavaExtractMethod", function()
            jdtls.extract_method()
          end, { desc = "Extract method" })

          -- Add command handler for _java.reloadBundles.command
          vim.lsp.commands["_java.reloadBundles.command"] = function()
            -- No-op handler to suppress the error
            return {}
          end
        end,
      }

          -- Start or attach to jdtls
          jdtls.start_or_attach(config)
        end,
        once = true,
      })
    end,
  },

  -- Ensure JDTLS is installed via Mason
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "jdtls",
        "java-test",
        "java-debug-adapter",
      })
    end,
  },

  -- Configure LSP settings for Java
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Disable jdtls in lspconfig as we use nvim-jdtls
        jdtls = {
          -- This will be handled by nvim-jdtls
          setup = false,
        },
      },
    },
  },

  -- Add Java snippets
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
  },

  -- Treesitter support for Java
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "java" })
      end
    end,
  },
}
