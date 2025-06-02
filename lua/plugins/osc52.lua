return {
  "ojroques/nvim-osc52",
  config = function()
    -- Only enable OSC52 if running over SSH
    if vim.env.SSH_CONNECTION then
      require("osc52").setup {
        max_length = 0,
        silent = false,
        trim = false,
      }

      local function copy()
        if vim.v.event.operator == 'y' and vim.v.event.regname == '' then
          require('osc52').copy_register('')
        end
      end

      vim.api.nvim_create_autocmd('TextYankPost', { callback = copy })
    end
  end,
}

