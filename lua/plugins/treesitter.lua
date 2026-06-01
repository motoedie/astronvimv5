-- Customize Treesitter
-- --------------------
-- In AstroNvim v6, nvim-treesitter is only a parser download utility.
-- Treesitter features (highlight/indent/ensure_installed) are configured via AstroCore.

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    treesitter = {
      highlight = true, -- enable/disable treesitter based highlighting
      indent = true, -- enable/disable treesitter based indentation
      ensure_installed = {
        "lua",
        "vim",
        -- add more arguments for adding more treesitter parsers
        "typescript",
        "tsx",
        "sql",
        "jsdoc",
      },
    },
  },
}
