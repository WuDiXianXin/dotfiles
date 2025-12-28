return {
  "OXY2DEV/markview.nvim",
  branch = 'main',
  lazy = false,
  dependencies = { "saghen/blink.cmp" },

  config = function()
    local presets = require("markview.presets");

    require("markview").setup({
      markdown = {
        headings = presets.headings.arrowed,
        -- headings = vim.tbl_deep_extend("force", presets.headings.arrowed, presets.headings.numbered),
        horizontal_rules = presets.horizontal_rules.arrowed,
        tables = presets.tables.rounded,
        checkboxes = presets.checkboxes.nerd,
      }
    });
  end,
};
