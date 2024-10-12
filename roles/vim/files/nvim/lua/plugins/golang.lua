-- :GoInstallBinaries

return {
  {
    "nvim-neotest/nvim-nio",
  },
  {
    "fatih/vim-go",
    config = function()
      -- Disable vim-go auto-formatting and auto-imports
      vim.g.go_fmt_autosave = 0
      vim.g.go_fmt_command = "" -- Disables specific gofmt commands
      vim.g.go_imports_autosave = 0 -- Disables automatic imports on save
      vim.g.go_metalinter_autosave = 0 -- Disables auto-linting
    end,
  },
}
