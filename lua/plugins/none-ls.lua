-- Biome formatting lives in conform.nvim (typescript.lua). Biome LSP is via mason/astrolsp for lint.
-- No null-ls sources — avoids a third biome formatter fighting conform.

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = { sources = {} },
}
