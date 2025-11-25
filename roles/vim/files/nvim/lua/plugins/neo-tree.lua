return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      position = "left",
      width = 40,
      -- Allow resizing with mouse
      mappings = {
        ["<cr>"] = "open",
        ["l"] = "open",
        ["h"] = "close_node",
        ["<2-LeftMouse>"] = "open",
        ["<RightMouse>"] = "open_vsplit",
        -- Resize mappings
        ["<C-w><"] = "resize_window_narrower",
        ["<C-w>>"] = "resize_window_wider",
        ["<C-w>="] = "resize_window_equal",
      },
    },
    filesystem = {
      -- Follow the current file
      follow_current_file = {
        enabled = true,
      },
      -- Use git status colors
      use_libuv_file_watcher = true,
    },
    -- Enable resizing
    enable_diagnostics = true,
    enable_git_status = true,
  },
}
