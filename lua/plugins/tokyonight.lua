return {
  "folke/tokyonight.nvim",
  opts = {
    transparent = true,
    style = "moon",
    styles = {
      keywords = { italic = false },
    },
    on_highlights = function(hl, c)
      hl.CursorLine = {
        bg = c.bg_dark,
      }
      hl.DiagnosticUnnecessary = {
        fg = c.comment,
      }
    end,
    on_colors = function(colors) colors.bg_statusline = colors.none end,
  },
}
