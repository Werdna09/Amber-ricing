-- Amber Neovim v1: live colors from the same Theme Bank used by Quickshell.
-- This is an overlay on the existing Sonokai colorscheme; plugin specs, LSP,
-- VimTeX, keymaps and other user settings are not replaced.
local M = {}

local uv = vim.uv or vim.loop
local source = debug.getinfo(1, "S").source
local path = source:sub(1, 1) == "@" and source:sub(2) or source
local resolved = uv.fs_realpath(path) or path
local root = resolved
for _ = 1, 5 do
  root = vim.fs.dirname(root)
end
local theme_dir = root .. "/shell/theme/"
local bank_path = theme_dir .. "palettes.json"
local selection_path = theme_dir .. "selection.json"

local current = nil
local last_fingerprint = nil
local timer = nil

local function load_json(file)
  local ok, lines = pcall(vim.fn.readfile, file)
  if not ok then return nil end
  local decoded, result = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not decoded or type(result) ~= "table" then return nil end
  return result
end

local function palette()
  local bank = load_json(bank_path)
  if not bank or not vim.islist(bank) then return nil end
  local selection = load_json(selection_path)
  local id = (selection and type(selection.selected) == "string") and selection.selected or "first-flame"
  local fallback = nil
  for _, entry in ipairs(bank) do
    if type(entry) == "table" then
      if entry.id == id then return entry end
      if entry.id == "first-flame" then fallback = entry end
    end
  end
  return fallback or bank[1]
end

local function valid_hex(s)
  return type(s) == "string" and s:match("^#%x%x%x%x%x%x$") ~= nil
end

local function mix(a, b, fraction)
  local parts = {}
  for i = 2, 6, 2 do
    local x = tonumber(a:sub(i, i + 1), 16)
    local y = tonumber(b:sub(i, i + 1), 16)
    parts[#parts + 1] = string.format("%02X", math.floor(x * (1 - fraction) + y * fraction + 0.5))
  end
  return "#" .. table.concat(parts)
end

local function derive(entry)
  if type(entry) ~= "table" or type(entry.colors) ~= "table" then return nil end
  local c = entry.colors
  for _, key in ipairs({ "background", "surface", "border", "muted", "accent", "text" }) do
    if not valid_hex(c[key]) then return nil end
  end
  local bg, surface, border, muted, accent, fg = c.background, c.surface, c.border, c.muted, c.accent, c.text
  return {
    bg = bg, surface = surface, border = border, muted = muted, accent = accent, fg = fg,
    surface_light = mix(surface, accent, 0.16),
    selection = mix(surface, accent, 0.32),
    dark_fg = mix(fg, bg, 0.62),
    red = mix("#B97870", accent, 0.16),
    green = mix("#94AA83", accent, 0.15),
    yellow = mix("#CEB176", accent, 0.34),
    blue = mix("#839CAF", accent, 0.14),
    magenta = mix("#AD90AD", accent, 0.15),
    cyan = mix("#7FA6A5", accent, 0.17),
  }
end

local function set(group, settings)
  vim.api.nvim_set_hl(0, group, settings)
end

local function apply(entry)
  local c = derive(entry)
  if not c then return end
  local bg, surface, border, muted, accent, fg = c.bg, c.surface, c.border, c.muted, c.accent, c.fg
  vim.o.termguicolors = true
  -- Base editor chrome
  local groups = {
    Normal = { fg = fg, bg = bg },
    NormalNC = { fg = fg, bg = bg },
    NormalFloat = { fg = fg, bg = surface },
    FloatBorder = { fg = border, bg = surface },
    FloatTitle = { fg = accent, bg = surface, bold = true },
    FloatFooter = { fg = muted, bg = surface },
    CursorLine = { bg = surface },
    CursorColumn = { bg = surface },
    ColorColumn = { bg = surface },
    CursorLineNr = { fg = accent, bg = surface, bold = true },
    CursorLineSign = { bg = surface },
    CursorLineFold = { bg = surface },
    LineNr = { fg = muted, bg = bg },
    LineNrAbove = { fg = muted, bg = bg },
    LineNrBelow = { fg = muted, bg = bg },
    SignColumn = { fg = muted, bg = bg },
    FoldColumn = { fg = muted, bg = bg },
    Folded = { fg = muted, bg = surface },
    EndOfBuffer = { fg = bg, bg = bg },
    WinSeparator = { fg = border, bg = bg },
    VertSplit = { fg = border, bg = bg },
    StatusLine = { fg = fg, bg = surface, bold = true },
    StatusLineNC = { fg = muted, bg = surface },
    TabLine = { fg = muted, bg = surface },
    TabLineFill = { bg = bg },
    TabLineSel = { fg = accent, bg = surface, bold = true },
    WildMenu = { fg = bg, bg = accent, bold = true },
    Pmenu = { fg = fg, bg = surface },
    PmenuSel = { fg = bg, bg = accent, bold = true },
    PmenuSbar = { bg = border },
    PmenuThumb = { bg = accent },
    PmenuMatch = { fg = accent, bg = surface, bold = true },
    PmenuMatchSel = { fg = bg, bg = accent, bold = true },
    Visual = { bg = c.selection },
    VisualNOS = { bg = c.selection },
    Search = { fg = bg, bg = c.yellow },
    IncSearch = { fg = bg, bg = accent, bold = true },
    CurSearch = { fg = bg, bg = accent, bold = true },
    Substitute = { fg = bg, bg = c.cyan },
    MatchParen = { fg = accent, bg = c.surface_light, bold = true },
    Directory = { fg = c.blue },
    Title = { fg = accent, bold = true },
    Question = { fg = c.green },
    MoreMsg = { fg = c.green },
    ModeMsg = { fg = accent },
    WarningMsg = { fg = c.yellow },
    ErrorMsg = { fg = c.red, bold = true },
    NonText = { fg = border },
    SpecialKey = { fg = border },
    Whitespace = { fg = border },
    Conceal = { fg = muted },
    QuickFixLine = { bg = c.selection },
    DiffAdd = { fg = c.green, bg = mix(bg, c.green, 0.17) },
    DiffChange = { fg = c.blue, bg = mix(bg, c.blue, 0.14) },
    DiffDelete = { fg = c.red, bg = mix(bg, c.red, 0.15) },
    DiffText = { fg = fg, bg = c.selection, bold = true },
    -- Syntax, including legacy Vim and Treesitter names
    Comment = { fg = muted, italic = true },
    Constant = { fg = c.magenta },
    String = { fg = c.green },
    Character = { fg = c.green },
    Number = { fg = c.yellow },
    Boolean = { fg = c.yellow },
    Float = { fg = c.yellow },
    Identifier = { fg = fg },
    Function = { fg = c.blue },
    Statement = { fg = accent },
    Conditional = { fg = c.red },
    Repeat = { fg = c.red },
    Label = { fg = accent },
    Operator = { fg = accent },
    Keyword = { fg = c.red },
    Exception = { fg = c.red },
    PreProc = { fg = c.magenta },
    Include = { fg = c.magenta },
    Define = { fg = c.magenta },
    Macro = { fg = c.magenta },
    Type = { fg = c.cyan },
    StorageClass = { fg = c.cyan },
    Structure = { fg = c.cyan },
    Typedef = { fg = c.cyan },
    Special = { fg = accent },
    SpecialChar = { fg = c.yellow },
    Tag = { fg = c.blue },
    Delimiter = { fg = fg },
    SpecialComment = { fg = muted, italic = true },
    Todo = { fg = bg, bg = accent, bold = true },
    Underlined = { fg = c.blue, underline = true },
    Error = { fg = c.red, bold = true },
    -- Diagnostics
    DiagnosticError = { fg = c.red },
    DiagnosticWarn = { fg = c.yellow },
    DiagnosticInfo = { fg = c.blue },
    DiagnosticHint = { fg = c.cyan },
    DiagnosticOk = { fg = c.green },
    DiagnosticSignError = { fg = c.red, bg = bg },
    DiagnosticSignWarn = { fg = c.yellow, bg = bg },
    DiagnosticSignInfo = { fg = c.blue, bg = bg },
    DiagnosticSignHint = { fg = c.cyan, bg = bg },
    DiagnosticVirtualTextError = { fg = c.red, bg = mix(bg, c.red, 0.12) },
    DiagnosticVirtualTextWarn = { fg = c.yellow, bg = mix(bg, c.yellow, 0.12) },
    DiagnosticVirtualTextInfo = { fg = c.blue, bg = mix(bg, c.blue, 0.12) },
    DiagnosticVirtualTextHint = { fg = c.cyan, bg = mix(bg, c.cyan, 0.12) },
    DiagnosticUnderlineError = { sp = c.red, undercurl = true },
    DiagnosticUnderlineWarn = { sp = c.yellow, undercurl = true },
    DiagnosticUnderlineInfo = { sp = c.blue, undercurl = true },
    DiagnosticUnderlineHint = { sp = c.cyan, undercurl = true },
    -- Git / completion / file picker UI
    GitSignsAdd = { fg = c.green },
    GitSignsChange = { fg = c.blue },
    GitSignsDelete = { fg = c.red },
    TelescopeNormal = { fg = fg, bg = bg },
    TelescopeBorder = { fg = border, bg = bg },
    TelescopePromptNormal = { fg = fg, bg = surface },
    TelescopePromptBorder = { fg = border, bg = surface },
    TelescopePromptTitle = { fg = accent, bg = surface, bold = true },
    TelescopeResultsTitle = { fg = accent, bg = bg, bold = true },
    TelescopePreviewTitle = { fg = accent, bg = bg, bold = true },
    TelescopeSelection = { fg = fg, bg = surface, bold = true },
    TelescopeMatching = { fg = accent, bold = true },
    CmpItemAbbr = { fg = fg },
    CmpItemAbbrMatch = { fg = accent, bold = true },
    CmpItemAbbrMatchFuzzy = { fg = accent },
    CmpItemKind = { fg = c.cyan },
    CmpItemMenu = { fg = muted },
    -- VimTeX and modern markdown/LaTeX capture groups
    texCmd = { fg = accent },
    texMathCmd = { fg = c.magenta },
    texMathZone = { fg = c.cyan },
    texSection = { fg = accent, bold = true },
  }
  for name, value in pairs(groups) do set(name, value) end

  local captures = {
    ["@comment"] = { fg = muted, italic = true },
    ["@string"] = { fg = c.green },
    ["@string.escape"] = { fg = c.yellow },
    ["@character"] = { fg = c.green },
    ["@number"] = { fg = c.yellow },
    ["@number.float"] = { fg = c.yellow },
    ["@boolean"] = { fg = c.yellow },
    ["@constant"] = { fg = c.magenta },
    ["@constant.builtin"] = { fg = c.magenta },
    ["@variable"] = { fg = fg },
    ["@variable.builtin"] = { fg = accent },
    ["@variable.parameter"] = { fg = fg },
    ["@property"] = { fg = fg },
    ["@function"] = { fg = c.blue },
    ["@function.call"] = { fg = c.blue },
    ["@function.builtin"] = { fg = c.blue },
    ["@method"] = { fg = c.blue },
    ["@method.call"] = { fg = c.blue },
    ["@constructor"] = { fg = c.cyan },
    ["@keyword"] = { fg = c.red },
    ["@keyword.function"] = { fg = c.red },
    ["@keyword.return"] = { fg = c.red },
    ["@keyword.operator"] = { fg = accent },
    ["@operator"] = { fg = accent },
    ["@type"] = { fg = c.cyan },
    ["@type.builtin"] = { fg = c.cyan },
    ["@attribute"] = { fg = c.magenta },
    ["@punctuation.delimiter"] = { fg = fg },
    ["@punctuation.bracket"] = { fg = fg },
    ["@tag"] = { fg = c.blue },
    ["@tag.attribute"] = { fg = c.cyan },
    ["@markup.heading"] = { fg = accent, bold = true },
    ["@markup.link"] = { fg = c.blue, underline = true },
    ["@markup.link.url"] = { fg = c.blue, underline = true },
    ["@markup.math"] = { fg = c.cyan },
  }
  for name, value in pairs(captures) do set(name, value) end

  local ansi = {
    mix(bg, "#090A0B", 0.28), c.red, c.green, c.yellow,
    c.blue, c.magenta, c.cyan, fg,
    muted, mix(c.red, fg, 0.23), mix(c.green, fg, 0.23),
    mix(c.yellow, fg, 0.23), mix(c.blue, fg, 0.23),
    mix(c.magenta, fg, 0.23), mix(c.cyan, fg, 0.23), fg,
  }
  for i, color in ipairs(ansi) do vim.g["terminal_color_" .. (i - 1)] = color end
  vim.g.amber_palette = entry.id
  vim.g.amber_palette_name = entry.name
  vim.cmd("redraw")
end

local function tick()
  local entry = palette()
  if not entry then return end
  local c = entry.colors
  if type(c) ~= "table" then return end
  local fingerprint = table.concat({
    tostring(entry.id), tostring(c.background), tostring(c.surface),
    tostring(c.border), tostring(c.muted), tostring(c.accent), tostring(c.text),
  }, ":")
  if fingerprint == last_fingerprint then return end
  if not derive(entry) then return end
  last_fingerprint = fingerprint
  current = entry
  apply(entry)
end

function M.setup()
  if vim.g.amber_neovim_started then return end
  vim.g.amber_neovim_started = true
  local group = vim.api.nvim_create_augroup("AmberThemeBank", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      vim.schedule(function()
        if current then apply(current) end
      end)
    end,
  })
  vim.api.nvim_create_autocmd({ "VimEnter" }, {
    group = group,
    callback = function()
      vim.schedule(function()
        if current then apply(current) end
      end)
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group, pattern = "VeryLazy",
    callback = function()
      vim.schedule(function()
        if current then apply(current) end
      end)
    end,
  })
  tick()
  -- FileView writes a small JSON file; polling is resilient to in-place writes
  -- and atomic replacement. Recoloring only happens after palette changes.
  timer = uv.new_timer()
  if timer then timer:start(1250, 1250, vim.schedule_wrap(tick)) end
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    once = true,
    callback = function()
      if timer and not timer:is_closing() then timer:stop(); timer:close() end
      timer = nil
    end,
  })
  vim.api.nvim_create_user_command("AmberTheme", function()
    tick()
    vim.notify("Amber Theme Bank: " .. tostring(vim.g.amber_palette_name or "není dostupná"))
  end, { desc = "Check Amber Theme Bank selection" })
end

return M
