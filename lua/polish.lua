-- :CopilotCreateTest — generate Vitest/RTL tests into <file>.test.ts[x]
vim.api.nvim_create_user_command("CopilotCreateTest", function()
  -- lazy-load CopilotChat if needed
  pcall(function() require("lazy").load { plugins = { "CopilotC-Nvim/CopilotChat.nvim" } } end)

  local ok_chat, chat = pcall(require, "CopilotChat")
  if not ok_chat then
    vim.notify("CopilotCreateTest: CopilotChat.nvim not available", vim.log.levels.ERROR)
    return
  end

  local src_path = vim.api.nvim_buf_get_name(0)
  if src_path == "" then
    vim.notify("CopilotCreateTest: save the current file first", vim.log.levels.WARN)
    return
  end

  -- e.g. Foo.tsx -> Foo.test.tsx ; bar.ts -> bar.test.ts
  local test_path = src_path:gsub("(%.[tj]sx?)$", ".test%1")
  if test_path == src_path then
    vim.notify("CopilotCreateTest: could not derive test filename", vim.log.levels.ERROR)
    return
  end

  -- sanitize Copilot output into plain test file contents
  local function strip_fences(text)
    text = tostring(text or "")
    -- keep only first fenced block if present
    local only = text:match "^%s*```[%w%-%_%.%s]*%s*(.-)%s*```%s*$"
    return (only or text)
  end

  local function sanitize_test_content(text)
    text = strip_fences(text):gsub("\r\n", "\n")

    -- 1) Kill classic metadata variants at the very start
    --    e.g. "path=/... start_line=1 end_line=97"
    text = text:gsub("^path=%S+%s+start_line=%d+%s+end_line=%d+%s*\n", "")
    text = text:gsub("^path=%S+%s*\n", "")
    text = text:gsub("^start_line=%d+%s*\n", "")
    text = text:gsub("^end_line=%d+%s*\n", "")
    text = text:gsub("^%s*[#/%-]+%s*[Pp]ath:%s*.-\n", "")

    -- 2) Kill the new mutant you’re seeing:
    --    "=/Users/... ExtensionsPage.test.tsx start_line=1 end_line=97"
    text = text:gsub("^=%S+%s+start_line=%d+%s+end_line=%d+%s*\n", "")
    --    or a bare "=<path>" line
    text = text:gsub("^=%S+%s*\n", "")

    -- 3) As an extra safety: remove any *leading* lines that look like key=value junk
    --    (but stop as soon as we hit real code)
    local cleaned, started = {}, false
    for line in (text .. "\n"):gmatch "([^\n]*)\n" do
      local is_meta = not started
        and (
          line:match "^%s*$"
          or line:match "^%s*[%w_]*%s*=%S+" -- foo=/bar or foo=123
          or line:match "%f[%a]start_line%s*=%d+"
          or line:match "%f[%a]end_line%s*=%d+"
        )
      if not is_meta then
        started = true
        table.insert(cleaned, line)
      end
    end

    local out = table.concat(cleaned, "\n")
    -- Trim extra leading/trailing blank lines
    out = out:gsub("^%s*\n", ""):gsub("\n%s*$", "\n")
    return out
  end

  local function write_file(path, data)
    local dir = vim.fn.fnamemodify(path, ":h")
    if dir ~= "" and vim.fn.isdirectory(dir) == 0 then vim.fn.mkdir(dir, "p") end
    local fd = vim.loop.fs_open(path, "w", 420) -- 0644
    if not fd then return false end
    vim.loop.fs_write(fd, data, -1)
    vim.loop.fs_close(fd)
    return true
  end

  local prompt = table.concat({
    ("#file:%s"):format(src_path),
    "Generate comprehensive unit tests for this file using Vitest and React Testing Library.",
    "Cover edge cases, events, async flows, and accessibility.",
    "Return ONLY the test file contents (no explanations).",
  }, "\n")

  chat.ask(prompt, {
    callback = function(resp)
      local text
      if type(resp) == "string" then
        text = resp
      elseif type(resp) == "table" then
        text = resp.text or resp.content or resp.message or resp.body
        if not text and resp.choices and resp.choices[1] and resp.choices[1].message then
          text = resp.choices[1].message.content
        end
      end
      if not text or text == "" then
        local ok_last, last = pcall(require("CopilotChat").response)
        if ok_last and type(last) == "string" and last ~= "" then text = last end
      end

      text = sanitize_test_content(text)
      if text == "" then
        vim.notify("CopilotCreateTest: empty/metadata-only response from Copilot", vim.log.levels.WARN)
        return
      end

      if write_file(test_path, text) then
        vim.cmd.edit(vim.fn.fnameescape(test_path))
        vim.notify("CopilotCreateTest: created " .. test_path, vim.log.levels.INFO)
      else
        vim.notify("CopilotCreateTest: failed to write " .. test_path, vim.log.levels.ERROR)
      end
    end,
  })
end, {})
