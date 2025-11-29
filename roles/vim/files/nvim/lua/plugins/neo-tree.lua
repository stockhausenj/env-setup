return {
  "nvim-neo-tree/neo-tree.nvim",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
  },
  opts = {
    close_if_last_window = false,
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,
    -- Prevent Neo-tree from opening files in its own window
    open_files_do_not_replace_types = { "terminal", "trouble", "qf", "edgy", "neo-tree" },
    default_component_configs = {
      indent = {
        with_expanders = true,
      },
    },
    window = {
      position = "left",
      width = 30,
      mappings = {
        ["<cr>"] = "open_with_window_picker",
        ["l"] = "open_with_window_picker",
        ["h"] = "close_node",
        ["<2-LeftMouse>"] = "open_with_window_picker",
        ["<RightMouse>"] = "open_vsplit",
        ["s"] = "open_split",
        ["v"] = "open_vsplit",
      },
    },
    filesystem = {
      follow_current_file = {
        enabled = true,
      },
      use_libuv_file_watcher = true,
    },
  },
}
