-- These are functions that are used within the Lua
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

local function string_starts(String, Start)
  return string.sub(String, 1, string.len(Start)) == Start
end

local function press_enter()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", false, true, true), "n", false)
end

local function get_line_number()
  return vim.api.nvim_win_get_cursor(0)[1]
end


local merge = function(...)
  local res = {}
  for _, t in ipairs({ ... }) do
    for _, value in ipairs(t) do
      table.insert(res, value)
    end
  end
  return res
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

local basename = function(str)
  local name = string.gsub(str, "(.*/)(.*)", "%2")
  return name
end

local get_register = function(char)
  return vim.api.nvim_exec([[echo getreg(']] .. char .. [[')]], true):gsub("[\n\r]", "^J")
end

local get_os = function()
  return vim.loop.os_uname().sysname
end

local split = function(str, delimiter)
  local result = {}
  for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match)
  end
  return result
end

return {
  get_os = get_os,
  get_home = function()
    return os.getenv("HOME")
  end,
  get_register = get_register,
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
  jump_to_line = function(search_text)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for i, line in ipairs(lines) do
      if string.find(line, search_text, 1, true) then
        vim.fn.cursor({ i, 1 })
        return true
      end
    end
    return false
  end,
  get_buffer_name = function()
    return vim.fn.expand("%")
  end,
  current_dir = function()
    return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  end,
  get_line_number = get_line_number,
  get_line_content = function()
    return vim.api.nvim_buf_get_lines(0, get_line_number() - 1, get_line_number(), false)[1]
  end,
  make_words_from_string = function(s)
    local words = {}
    for word in s:gmatch("%w+") do table.insert(words, word) end
    return words
  end,
  open_url = function(url)
    local opener = get_os() == "Linux" and "xdg-open" or "open"
    vim.cmd("exec \"!" .. opener .. " '" .. url .. "'\"")
  end,
  get_branch_name = function()
    local is_git_branch = io.popen("git rev-parse --is-inside-work-tree 2>/dev/null"):read("*a")
    if is_git_branch == "true\n" then
      for line in io.popen("git branch 2>/dev/null"):lines() do
        local current_branch = line:match("%* (.+)$")
        if current_branch then
          return current_branch
        end
      end
    end
  end,
  get_root_git_dir = function()
    local cur_path = vim.fn.expand("%:p")
    local dir = vim.fs.find(".git", {
      path = cur_path,
      upward = true,
      type = "directory"
    })[1]
    if dir == nil then return dir end
    return dir:sub(1, -5)
  end,
  branch_exists = function(b)
    local is_git_branch = io.popen("git rev-parse --is-inside-work-tree 2>/dev/null"):read("*a")
    if is_git_branch == "true\n" then
      for line in io.popen("git branch 2>/dev/null"):lines() do
        line = line:gsub("%s+", "")
        if line == b then
          return true
        end
      end
    end
    return false
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
  reload_plugin = function(plugin)
    for k in pairs(package.loaded) do
      if k:match(plugin) then
        package.loaded[k] = nil
        require(k)
      end
    end
  end,
  press_enter = press_enter,
  -- TODO: Open file in telescope file_browser
  open_file_in_file_browser = function(entry, bufnr)
    local path_ok, path = pcall(require, "cmp_nvim_lsp")
    if not path_ok then
      require("notify")("Plenary is not installed", "error")
      return
    end

    local entry_path = path:new(entry):parent():absolute()
    entry_path = path:new(entry):parent():absolute()
    entry_path = entry_path:gsub("\\", "\\\\")

    require("telescope").extensions.file_browser.file_browser({ path = entry_path, quiet = true })

    local file_name = nil
    for s in string.gmatch(entry, "[^/]+") do
      file_name = s
    end

    local actions = require("telescope.actions")
    vim.api.nvim_feedkeys("i" .. file_name, "i", false)
    actions.select(bufnr)
  end,
  basename = basename,
  dirname = function(str)
    local name = string.gsub(str, "(.*/)(.*)", "%1")
    return name
  end,
  trim_file_path = function(full_path, dir)
    local dir_pattern = "^" .. dir:gsub("/", "%%/") .. "/"
    local trimmedPath = full_path:gsub(dir_pattern, "")
    return trimmedPath
  end,
  string_starts = string_starts,
  copy_absolute_filepath = function(quiet)
    vim.api.nvim_feedkeys(":let @+=expand('%:p')", "n", false)
    press_enter()
    if not quiet then
      require("notify")('Copied filepath.', vim.log.levels.INFO)
    end
  end,
  copy_relative_dir = function(quiet)
    vim.api.nvim_feedkeys(":let @+=expand('%:h')", "n", false)
    press_enter()
    if not quiet then
      require("notify")('Copied directory path.', vim.log.levels.INFO)
    end
  end,
  copy_relative_filepath = function(quiet)
    local res = vim.fn.fnamemodify(vim.fn.expand('%:h'), ':p:~:.')
    vim.fn.setreg("+", res)
    if not quiet then
      require("notify")('Copied relative path.', vim.log.levels.INFO)
    end

    return res
  end,
  copy_file_name = function(quiet)
    local buf_name = vim.api.nvim_buf_get_name(0)
    local base = basename(buf_name)
    vim.fn.setreg("+", base)
    if not quiet then
      require("notify")('Copied file name.', vim.log.levels.INFO)
    end
    return base
  end,
  return_bare_file_name = function()
    local full_file_name = vim.fn.expand('%:t')
    local file_name = ''
    for part in string.gmatch(full_file_name, "[^.]+") do
      file_name = part
      break
    end
    return file_name
  end,
  get_buf_by_name = function(name, starts_with)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if starts_with then
        if string_starts(buf_name, name) then
          return buf
        end
      end
      local base_name = basename(buf_name)
      if base_name == name then
        return buf
      end
    end
    return -1
  end,
  get_win_by_buf_name = function(name)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local buf_name = vim.api.nvim_buf_get_name(buf)
      local base_name = basename(buf_name)
      if base_name == name then
        return win
      end
    end
    return -1
  end,
  get_tab_by_buf_name = function(name, starts_with)
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
      local win = vim.api.nvim_tabpage_get_win(tab)
      local buf = vim.api.nvim_win_get_buf(win)
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if starts_with then
        if string_starts(buf_name, name) then
          return tab
        end
      else
        local base_name = basename(buf_name)
        if base_name == name then
          return tab
        end
      end
    end
    return -1
  end,
  resize_vertical_splits = function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>=", false, true, true), "n", false)
  end,
  get_current_buf_name = function()
    local buf_name = vim.api.nvim_buf_get_name(0)
    local base_name = basename(buf_name)
    return base_name
  end,
  get_word_under_cursor = function()
    return vim.fn.expand("<cword>")
  end,
  blank_line_below = function()
    vim.fn.append(vim.fn.line("."), "")
  end,
  blank_line_above = function()
    vim.fn.append(vim.fn.line(".") - 1, "")
  end,
  move_line_down = function()
    vim.api.nvim_feedkeys("ddp", "n", false)
  end,
  move_line_up = function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("dd<Up>P", false, true, true), "n", false)
  end,
  merge = merge,
  has_value = function(table, val)
    for _, value in ipairs(table) do
      if value == val then
        return true
      end
    end
    return false
  end,
}
