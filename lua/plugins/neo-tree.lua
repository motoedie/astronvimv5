return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = false,
    opts = function(_, opts)
      return require("astrocore").extend_tbl(opts, {
        sources = { "filesystem" },
        window = {
          width = 50,
          -- width = "fit_content",
        },
        filesystem = {
          filtered_items = {
            hide_dotfiles = false,
          },
        }
      })
    end,
  },
}
