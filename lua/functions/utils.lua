local async = require("plenary.async")
-- local f = require("functions")

-- These are functions that are used within the Lua
--
-- configuration and are not meant for export to the end
-- user.

-- Validates number + function for debounce, see https://gist.github.com/runiq/31aa5c4bf00f8e0843cd267880117201
local function td_validate(fn, ms)
  vim.validate({
    fn = { fn, "f" },
    ms = {
      ms,
      function(ms)
        return type(ms) == "number" and ms > 0
      end,
      "number > 0",
    },
  })
end

local function run_script(script_name, args)
  local nvim_scripts_dir = "~/.config/nvim/scripts"
  local f = nil
  if args == nil then
    f = io.popen(string.format("/bin/bash %1s/%2s", nvim_scripts_dir, script_name))
  else
    f = io.popen(string.format("/bin/bash %1s/%2s %3s", nvim_scripts_dir, script_name, args))
  end
  local output = f:read("*a")
  f:close()
  return output
end

return {
  get_os = function()
    return vim.loop.os_uname().sysname
  end,
  get_home = function()
    return os.getenv("HOME")
  end,
  get_register = function(char)
    return vim.api.nvim_exec([[echo getreg(']] .. char .. [[')]], true):gsub("[\n\r]", "^J")
  end,
  get_date_time = function()
    local date_table = os.date("*t")
    local hour, minute = date_table.hour, date_table.min
    local year, month, day = date_table.year, date_table.month, date_table.day -- date_table.wday to date_table.day
    local result = string.format("%02d-%02d-%04d__%d:%d", month, day, year, hour, minute)
    return result
  end,
  get_visual_selection = function()
    local modeInfo = vim.api.nvim_get_mode()
    local mode = modeInfo.mode

    local cursor = vim.api.nvim_win_get_cursor(0)
    local cline, ccol = cursor[1], cursor[2]
    local vline, vcol = vim.fn.line("v"), vim.fn.col("v")

    local sline, scol
    local eline, ecol
    if cline == vline then
      if ccol <= vcol then
        sline, scol = cline, ccol
        eline, ecol = vline, vcol
        scol = scol + 1
      else
        sline, scol = vline, vcol
        eline, ecol = cline, ccol
        ecol = ecol + 1
      end
    elseif cline < vline then
      sline, scol = cline, ccol
      eline, ecol = vline, vcol
      scol = scol + 1
    else
      sline, scol = vline, vcol
      eline, ecol = cline, ccol
      ecol = ecol + 1
    end

    if mode == "V" or mode == "CTRL-V" or mode == "\22" then
      scol = 1
      ecol = nil
    end

    local lines = vim.api.nvim_buf_get_lines(0, sline - 1, eline, 0)
    if #lines == 0 then
      return
    end

    local startText, endText
    if #lines == 1 then
      startText = string.sub(lines[1], scol, ecol)
    else
      startText = string.sub(lines[1], scol)
      endText = string.sub(lines[#lines], 1, ecol)
    end

    local selection = { startText }
    if #lines > 2 then
      vim.list_extend(selection, vim.list_slice(lines, 2, #lines - 1))
    end
    table.insert(selection, endText)

    return selection
  end,
  get_buffer_name = function()
    return vim.fn.expand("%")
  end,
  split = function(str, delimiter)
    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
      table.insert(result, match)
    end
    return result
  end,
  current_dir = function()
    return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  end,
  open_url = function(url)
    vim.cmd("exec \"!xdg-open '" .. url .. "'\"")
  end,
  get_branch_name = function()
    local is_git_branch = io.popen("git rev-parse --is-inside-work-tree 2>/dev/null"):read("*a")
    if is_git_branch == "true\n" then
      for line in io.popen("git branch 2>/dev/null"):lines() do
        local m = line:match("%* (.+)$")
        if m then
          return m
        end
      end
    end
  end,
  file_exists = function(name)
    local f = io.open(name, "r")
    return f ~= nil and io.close(f)
  end,
  escape_string = function(text)
    return text:gsub("([^%w])", "%%%1")
  end,
  debounce = function(fn, ms, first)
    td_validate(fn, ms)
    local timer = vim.loop.new_timer()
    local wrapped_fn

    if not first then
      function wrapped_fn(...)
        local argv = { ... }
        local argc = select("#", ...)

        timer:start(ms, 0, function()
          pcall(vim.schedule_wrap(fn), unpack(argv, 1, argc))
        end)
      end
    else
      local argv, argc
      function wrapped_fn(...)
        argv = argv or { ... }
        argc = argc or select("#", ...)

        timer:start(ms, 0, function()
          pcall(vim.schedule_wrap(fn), unpack(argv, 1, argc))
        end)
      end
    end
    return wrapped_fn, timer
  end,
  split_on = function(s, delimiter)
    local result = {}
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
      table.insert(result, match)
    end
    return result
  end,
  reload_plugin = function(plugin)
    for k in pairs(package.loaded) do
      if k:match(plugin) then
        package.loaded[k] = nil
        require(k)
      end
    end
  end,
  press_enter = function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", false, true, true), "n", false)
  end,
  -- TODO: Open file in telescope file_browser
  open_file_in_file_browser = function(entry, bufnr)
    local path_ok, path = pcall(require, "cmp_nvim_lsp")
    if not path_ok then
      print("Plenary is not installed")
      return
    end

    local entry_path = path:new(entry):parent():absolute()
    entry_path = path:new(entry):parent():absolute()
    entry_path = entry_path:gsub("\\", "\\\\")

    require("telescope").extensions.file_browser.file_browser({ path = entry_path })

    local file_name = nil
    for s in string.gmatch(entry, "[^/]+") do
      file_name = s
    end

    local actions = require("telescope.actions")
    vim.api.nvim_feedkeys("i" .. file_name, "i", false)
    actions.select(bufnr)
  end,
  basename = function(str)
    local name = string.gsub(str, "(.*/)(.*)", "%2")
    return name
  end,
  dirname = function(str)
    local name = string.gsub(str, "(.*/)(.*)", "%1")
    return name
  end,
  string_starts = function(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
  end,
  packer_sync = function()
    async.run(function()
      require("notify")('Syncing packer.')
    end)

    run_script("update-nvim-lockfile")

    local snap_shot_time = os.date("!%Y-%m-%dT%TZ")
    vim.cmd('PackerSnapshot ' .. snap_shot_time)
    vim.cmd('PackerSync')
  end
}
