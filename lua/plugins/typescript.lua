local function find_local_biome(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local startdir = (bufname ~= "" and vim.fs.dirname(bufname)) or vim.loop.cwd()
  local paths = vim.fs.find({ "node_modules/.bin/biome" }, { upward = true, path = startdir })
  return paths[1]
end

return {
  "stevearc/conform.nvim",
  event = "User AstroFile",
  cmd = "ConformInfo",
  specs = {
    { "AstroNvim/astrolsp", optional = true, opts = { formatting = { disabled = true } } },
    { "jay-babu/mason-null-ls.nvim", optional = true, opts = { methods = { formatting = false } } },
  },
  dependencies = {
    { "williamboman/mason.nvim", optional = true },
    {
      "AstroNvim/astrocore",
      opts = {
        options = { opt = { formatexpr = "v:lua.require'conform'.formatexpr()" } },
        commands = {
          Format = {
            function(args)
              local range = nil
              if args.count ~= -1 then
                local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
                range = { start = { args.line1, 0 }, ["end"] = { args.line2, end_line:len() } }
              end
              require("conform").format { async = true, lsp_format = "fallback", range = range }
            end,
            desc = "Format buffer",
            range = true,
          },
        },
        mappings = {
          n = {
            ["<Leader>lf"] = { function() vim.cmd.Format() end, desc = "Format buffer" },
            ["<Leader>uf"] = {
              function()
                if vim.b.autoformat == nil then
                  if vim.g.autoformat == nil then vim.g.autoformat = true end
                  vim.b.autoformat = vim.g.autoformat
                end
                vim.b.autoformat = not vim.b.autoformat
                require("astrocore").notify(
                  string.format("Buffer autoformatting %s", vim.b.autoformat and "on" or "off")
                )
              end,
              desc = "Toggle autoformatting (buffer)",
            },
            ["<Leader>uF"] = {
              function()
                if vim.g.autoformat == nil then vim.g.autoformat = true end
                vim.g.autoformat = not vim.g.autoformat
                vim.b.autoformat = nil
                require("astrocore").notify(
                  string.format("Global autoformatting %s", vim.g.autoformat and "on" or "off")
                )
              end,
              desc = "Toggle autoformatting (global)",
            },
          },
        },
      },
    },
  },

  opts = {
    format_on_save = function(bufnr)
      if vim.g.autoformat == nil then vim.g.autoformat = true end
      local autoformat = vim.b[bufnr].autoformat
      if autoformat == nil then autoformat = vim.g.autoformat end
      if autoformat then return { timeout_ms = 5000, lsp_format = "fallback" } end
    end,

    -- Define a formatter that runs `biome check` from your local node_modules.
    formatters = {
      biome_check = function(bufnr)
        local cmd = find_local_biome(bufnr) or "biome"
        return {
          command = cmd,
          args = { "check", "--fix", "--stdin-file-path", vim.api.nvim_buf_get_name(bufnr) },
          stdin = true,
        }
      end,
    },

    formatters_by_ft = {
      typescript = { "biome_check" },
      javascript = { "biome_check" },
      typescriptreact = { "biome_check" },
      javascriptreact = { "biome_check" },
      json = { "biome_check" },
      jsonc = { "biome_check" },
      markdown = { "biome_check" },
      toml = { "biome_check" },
    },
  },
}
