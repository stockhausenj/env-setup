return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        yaml = { "yamlfmt" },
      },
      formatters = {
        yamlfmt = {
          prepend_args = {
            "-formatter",
            "indent=2,include_document_start=false,retain_line_breaks_single=true,disallow_anchors=false,max_line_length=100,scan_folded_as_literal=false,indentless_arrays=true",
          },
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "yamlfmt" })
    end,
  },
}
