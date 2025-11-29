return {
  -- Override nvim-dap config to safely handle mason-nvim-dap
  {
    "mfussenegger/nvim-dap",
    optional = true,
    config = function()
      -- Safely setup mason-nvim-dap if available
      local has_mason_dap, mason_dap = pcall(require, "mason-nvim-dap")
      if has_mason_dap then
        mason_dap.setup(LazyVim.opts("mason-nvim-dap.nvim"))
      end

      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      for name, sign in pairs(LazyVim.config.icons.dap) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define(
          "Dap" .. name,
          { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
        )
      end

      -- setup dap config by VsCode launch.json file
      local vscode = require("dap.ext.vscode")
      local json = require("plenary.json")
      vscode.json_decode = function(str)
        return vim.json.decode(json.json_strip_comments(str))
      end
    end,
  },

  -- Install mason-nvim-dap
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = false,
  },
}
