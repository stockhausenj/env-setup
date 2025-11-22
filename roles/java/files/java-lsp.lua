-- Java LSP Configuration for LazyVim
-- Requirements:
--   - Java 21 support
--   - Lombok support (version 1.18.30+ for Java 21 compatibility)
--   - Annotation processing enabled
--   - macOS and Linux support
--   - Debug logging for troubleshooting

return {
  -- Disable LazyVim's default jdtls configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jdtls = {
          enabled = false,
        },
      },
      setup = {
        jdtls = function()
          return true -- Prevent default setup
        end,
      },
    },
  },

  -- Configure nvim-jdtls for Java development
  {
    "mfussenegger/nvim-jdtls",
    dependencies = { "mason-org/mason.nvim" },
    ft = { "java" },
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
          local jdtls = require("jdtls")

          -- Debug helper function
          local function debug_log(message, level)
            level = level or vim.log.levels.INFO
            if vim.env.DEBUG_JDTLS then
              vim.notify("[JDTLS] " .. message, level)
            end
          end

          -- ========================================
          -- Path Configuration
          -- ========================================
          local jdtls_install = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
          local java_debug_install = vim.fn.stdpath("data") .. "/mason/packages/java-debug-adapter"
          local java_test_install = vim.fn.stdpath("data") .. "/mason/packages/java-test"

          debug_log("JDTLS install path: " .. jdtls_install)
          debug_log("Java debug install path: " .. java_debug_install)
          debug_log("Java test install path: " .. java_test_install)

          -- ========================================
          -- Validate JDTLS Installation
          -- ========================================
          if vim.fn.isdirectory(jdtls_install) == 0 then
            vim.notify("JDTLS is not installed. Run :MasonInstall jdtls", vim.log.levels.ERROR)
            return
          end

          -- ========================================
          -- Lombok Configuration
          -- ========================================
          local lombok_jar = jdtls_install .. "/lombok.jar"
          local lombok_exists = vim.fn.filereadable(lombok_jar) == 1

          if lombok_exists then
            debug_log("Lombok found at: " .. lombok_jar)
            vim.notify("Lombok support enabled", vim.log.levels.INFO)
          else
            vim.notify("WARNING: lombok.jar not found at " .. lombok_jar .. ". Lombok annotations will not work!", vim.log.levels.WARN)
            debug_log("Lombok not found. Expected at: " .. lombok_jar, vim.log.levels.WARN)
          end

          -- ========================================
          -- Find JDTLS Launcher JAR
          -- ========================================
          local launcher_jar = vim.fn.glob(jdtls_install .. "/plugins/org.eclipse.equinox.launcher_*.jar")
          if launcher_jar == "" then
            vim.notify("JDTLS launcher JAR not found. Reinstall jdtls via :Mason", vim.log.levels.ERROR)
            return
          end
          debug_log("Launcher JAR: " .. launcher_jar)

          -- ========================================
          -- Platform Detection
          -- ========================================
          local os_config = "config_mac"
          if vim.fn.has("mac") == 1 then
            os_config = "config_mac"
            debug_log("Platform: macOS")
          elseif vim.fn.has("linux") == 1 then
            os_config = "config_linux"
            debug_log("Platform: Linux")
          else
            vim.notify("Unsupported platform. Only macOS and Linux are supported.", vim.log.levels.ERROR)
            return
          end

          local config_dir = jdtls_install .. "/" .. os_config
          if vim.fn.isdirectory(config_dir) == 0 then
            vim.notify("JDTLS config directory not found: " .. config_dir, vim.log.levels.ERROR)
            return
          end
          debug_log("Config directory: " .. config_dir)

          -- ========================================
          -- Workspace Configuration
          -- ========================================
          local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
          local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name
          debug_log("Workspace directory: " .. workspace_dir)

          -- ========================================
          -- Java Home Detection
          -- ========================================
          local java_home = ""
          if vim.fn.has("mac") == 1 then
            java_home = vim.fn.trim(vim.fn.system("/usr/libexec/java_home -v 21 2>/dev/null"))
            if vim.v.shell_error ~= 0 then
              vim.notify("Java 21 not found. Install Java 21 and try again.", vim.log.levels.ERROR)
              return
            end
          elseif vim.fn.has("linux") == 1 then
            -- Try common Java 21 installation paths on Linux
            local possible_paths = {
              "/usr/lib/jvm/java-21-openjdk",
              "/usr/lib/jvm/java-21-openjdk-amd64",
              "/usr/lib/jvm/jdk-21",
            }
            for _, path in ipairs(possible_paths) do
              if vim.fn.isdirectory(path) == 1 then
                java_home = path
                break
              end
            end
            if java_home == "" then
              java_home = vim.fn.trim(vim.fn.system("dirname $(dirname $(readlink -f $(which java))) 2>/dev/null"))
            end
          end

          if java_home == "" or vim.fn.isdirectory(java_home) == 0 then
            vim.notify("Could not detect Java 21 home directory", vim.log.levels.ERROR)
            return
          end
          debug_log("Java home: " .. java_home)

          -- ========================================
          -- Debug and Test Bundles
          -- ========================================
          local bundles = {}

          -- Java debug adapter
          if vim.fn.isdirectory(java_debug_install) == 1 then
            local debug_jars = vim.split(vim.fn.glob(java_debug_install .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"), "\n")
            vim.list_extend(bundles, debug_jars)
            debug_log("Added " .. #debug_jars .. " debug adapter bundle(s)")
          else
            debug_log("Java debug adapter not installed", vim.log.levels.WARN)
          end

          -- Java test runner
          if vim.fn.isdirectory(java_test_install) == 1 then
            local test_jars = vim.split(vim.fn.glob(java_test_install .. "/extension/server/*.jar"), "\n")
            vim.list_extend(bundles, test_jars)
            debug_log("Added " .. #test_jars .. " test runner bundle(s)")
          else
            debug_log("Java test runner not installed", vim.log.levels.WARN)
          end

          -- ========================================
          -- Build JDTLS Command
          -- ========================================
          local cmd = {
            "java",

            -- JVM Options
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-Xms1g",
            "-Xmx2g",
            "-XX:+UseG1GC",
            "-XX:+UseStringDeduplication",
          }

          -- Add Lombok as javaagent if available
          if lombok_exists then
            table.insert(cmd, "-javaagent:" .. lombok_jar)
            debug_log("Lombok javaagent added")
          end

          -- Java 21 Module Configuration
          -- These are critical for annotation processing (required by Lombok)
          vim.list_extend(cmd, {
            -- Add all system modules including compiler modules
            "--add-modules=ALL-SYSTEM",

            -- Export compiler internals for annotation processing
            -- These are required for Lombok and other annotation processors
            "--add-exports", "jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED",
            "--add-exports", "jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED",
            "--add-exports", "jdk.compiler/com.sun.tools.javac.comp=ALL-UNNAMED",
            "--add-exports", "jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED",
            "--add-exports", "jdk.compiler/com.sun.tools.javac.main=ALL-UNNAMED",
            "--add-exports", "jdk.compiler/com.sun.tools.javac.model=ALL-UNNAMED",
            "--add-exports", "jdk.compiler/com.sun.tools.javac.parser=ALL-UNNAMED",
            "--add-exports", "jdk.compiler/com.sun.tools.javac.processing=ALL-UNNAMED",
            "--add-exports", "jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED",
            "--add-exports", "jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED",

            -- Open reflection access for frameworks
            "--add-opens", "java.base/java.util=ALL-UNNAMED",
            "--add-opens", "java.base/java.lang=ALL-UNNAMED",

            -- JDTLS launcher and configuration
            "-jar", launcher_jar,
            "-configuration", config_dir,
            "-data", workspace_dir,
          })

          debug_log("Full command: " .. table.concat(cmd, " "))

          -- ========================================
          -- JDTLS Configuration
          -- ========================================
          local config = {
            cmd = cmd,

            root_dir = require("jdtls.setup").find_root({
              ".git",
              "mvnw",
              "gradlew",
              "pom.xml",
              "build.gradle",
              "build.gradle.kts",
            }),

            settings = {
              java = {
                -- Eclipse configuration
                eclipse = {
                  downloadSources = true,
                },

                -- Java runtime configuration
                configuration = {
                  updateBuildConfiguration = "interactive",
                  runtimes = {
                    {
                      name = "JavaSE-21",
                      path = java_home,
                      default = true,
                    },
                  },
                },

                -- Maven configuration
                maven = {
                  downloadSources = true,
                },

                -- Code lens
                implementationsCodeLens = {
                  enabled = true,
                },
                referencesCodeLens = {
                  enabled = true,
                },

                -- References
                references = {
                  includeDecompiledSources = true,
                },

                -- Formatting - DISABLED to prevent file corruption
                format = {
                  enabled = false,
                },

                -- Save actions - DISABLED to prevent file corruption
                saveActions = {
                  organizeImports = false,
                },

                -- Signature help
                signatureHelp = {
                  enabled = true
                },

                -- Content provider for decompilation
                contentProvider = {
                  preferred = "fernflower"
                },

                -- Completion settings
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
                  filteredTypes = {
                    "com.sun.*",
                    "io.micrometer.shaded.*",
                    "java.awt.*",
                    "jdk.*",
                    "sun.*",
                  },
                  importOrder = {
                    "java",
                    "javax",
                    "com",
                    "org",
                  },
                },

                -- Source organization
                sources = {
                  organizeImports = {
                    starThreshold = 9999,
                    staticStarThreshold = 9999,
                  },
                },

                -- Code generation
                codeGeneration = {
                  toString = {
                    template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                  },
                  hashCodeEquals = {
                    useJava7Objects = true,
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

            -- LSP capabilities
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

            -- Message handlers
            handlers = {
              ["language/status"] = function(_, result)
                debug_log("Language status: " .. vim.inspect(result))
              end,
              ["$/progress"] = function(_, result, ctx)
                -- Suppress progress messages unless debugging
                if vim.env.DEBUG_JDTLS then
                  debug_log("Progress: " .. vim.inspect(result))
                end
              end,
            },

            -- On attach callback
            on_attach = function(client, bufnr)
              -- Notify about configuration status
              vim.notify(string.format(
                "JDTLS started for project: %s\n  Java: %s\n  Lombok: %s\n  Workspace: %s",
                project_name,
                java_home,
                lombok_exists and "enabled" or "DISABLED",
                workspace_dir
              ), vim.log.levels.INFO)

              -- CRITICAL: Disable all formatting to prevent file corruption
              client.server_capabilities.documentFormattingProvider = false
              client.server_capabilities.documentRangeFormattingProvider = false
              client.server_capabilities.documentOnTypeFormattingProvider = nil

              -- Disable LazyVim's format on save for this buffer
              vim.b[bufnr].autoformat = false

              -- Create autocmd to prevent any format on save
              vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                callback = function()
                  -- Disable autoformat right before save
                  vim.b[bufnr].autoformat = false
                  if vim.env.DEBUG_JDTLS then
                    debug_log("BufWritePre: autoformat disabled")
                  end
                  return false -- Don't block the save
                end,
              })

              -- Also disable conform.nvim if it's loaded
              local ok, conform = pcall(require, "conform")
              if ok then
                vim.api.nvim_create_autocmd("BufWritePre", {
                  buffer = bufnr,
                  callback = function()
                    -- Return true to prevent conform from formatting
                    return true
                  end,
                })
              end

              -- Setup DAP for debugging
              jdtls.setup_dap({ hotcodereplace = "auto" })

              -- Setup test runner
              jdtls.setup.add_commands()

              -- ========================================
              -- Custom Commands
              -- ========================================

              vim.api.nvim_buf_create_user_command(bufnr, "JavaTestNearest", function()
                jdtls.test_nearest_method()
              end, { desc = "Test nearest method" })

              vim.api.nvim_buf_create_user_command(bufnr, "JavaTestClass", function()
                jdtls.test_class()
              end, { desc = "Test current class" })

              vim.api.nvim_buf_create_user_command(bufnr, "JavaOrganizeImports", function()
                jdtls.organize_imports()
              end, { desc = "Organize imports" })

              vim.api.nvim_buf_create_user_command(bufnr, "JavaExtractVariable", function()
                jdtls.extract_variable()
              end, { desc = "Extract variable" })

              vim.api.nvim_buf_create_user_command(bufnr, "JavaExtractMethod", function()
                jdtls.extract_method()
              end, { desc = "Extract method" })

              vim.api.nvim_buf_create_user_command(bufnr, "JavaCleanWorkspace", function()
                local choice = vim.fn.confirm("Clean JDTLS workspace and restart?", "&Yes\n&No", 2)
                if choice == 1 then
                  vim.fn.system("rm -rf " .. workspace_dir)
                  vim.cmd("LspRestart")
                  vim.notify("Workspace cleaned. LSP restarting...", vim.log.levels.INFO)
                end
              end, { desc = "Clean workspace and restart" })

              vim.api.nvim_buf_create_user_command(bufnr, "JavaStatus", function()
                vim.notify(string.format(
                  "JDTLS Configuration:\n" ..
                  "  Project: %s\n" ..
                  "  Java Home: %s\n" ..
                  "  Lombok: %s\n" ..
                  "  Workspace: %s\n" ..
                  "  Config Dir: %s\n" ..
                  "  Bundles: %d",
                  project_name,
                  java_home,
                  lombok_exists and lombok_jar or "NOT FOUND",
                  workspace_dir,
                  config_dir,
                  #bundles
                ), vim.log.levels.INFO)
              end, { desc = "Show JDTLS configuration status" })

              vim.api.nvim_buf_create_user_command(bufnr, "JavaFormat", function()
                vim.lsp.buf.format({ async = false })
              end, { desc = "Format Java file manually" })

              -- ========================================
              -- Which-Key Keybindings
              -- ========================================
              local wk_ok, wk = pcall(require, "which-key")
              if wk_ok then
                wk.add({
                  { "<leader>j", group = "java", buffer = bufnr },
                  { "<leader>jt", "<cmd>JavaTestClass<cr>", desc = "Test Class", buffer = bufnr },
                  { "<leader>jn", "<cmd>JavaTestNearest<cr>", desc = "Test Nearest", buffer = bufnr },
                  { "<leader>jo", "<cmd>JavaOrganizeImports<cr>", desc = "Organize Imports", buffer = bufnr },
                  { "<leader>jv", "<cmd>JavaExtractVariable<cr>", desc = "Extract Variable", buffer = bufnr, mode = "v" },
                  { "<leader>jm", "<cmd>JavaExtractMethod<cr>", desc = "Extract Method", buffer = bufnr, mode = "v" },
                  { "<leader>jc", "<cmd>JavaCleanWorkspace<cr>", desc = "Clean Workspace", buffer = bufnr },
                  { "<leader>js", "<cmd>JavaStatus<cr>", desc = "Show Status", buffer = bufnr },
                  { "<leader>jf", "<cmd>JavaFormat<cr>", desc = "Format", buffer = bufnr },
                })
              end

              -- Register command handlers
              vim.lsp.commands["_java.reloadBundles.command"] = function()
                return {}
              end
            end,
          }

          -- ========================================
          -- Start JDTLS
          -- ========================================
          debug_log("Starting JDTLS...")
          jdtls.start_or_attach(config)
        end,
        once = true,
      })
    end,
  },

  -- Ensure Mason packages are installed
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "jdtls",
        "java-test",
        "java-debug-adapter",
      })
    end,
  },

  -- Java snippets
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

  -- Which-Key integration for Java commands
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>j", group = "java", mode = "n" },
      },
    },
  },
}
