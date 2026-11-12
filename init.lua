---------------------------------------------------------------
-- General settings
---------------------------------------------------------------

-- set proper language (UTF-8 clipboard supoort) without aborting on error
local locale = "en_US.UTF-8"

local ok, err = pcall(vim.cmd.language, locale)

if not ok then
  vim.notify(
    ("Locale %q is unavailable: %s"):format(locale, err),
    vim.log.levels.ERROR
  )
end

-- setting tab size and so on
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- auto indent
vim.opt.autoindent = true

-- search settings
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- disable --INSERT--
vim.opt.showmode = false

-- don't scroll to the very bottom before moving the buffer
vim.opt.scrolloff = 8

-- line numbers
vim.opt.nu = true

-- relative line numbers
vim.opt.relativenumber = true

-- map leader
vim.g.mapleader = " "

-- remapping Ctrl+c to behave exactly like escape in insert mode
vim.keymap.set("i", "<C-c>", "<Esc>", { noremap = true })

-- remapping <leader>y to copy to clipboard quickly
vim.keymap.set("n", "<leader>y", '"+y', { noremap = true })
vim.keymap.set("x", "<leader>y", '"+y', { noremap = true })

-- move highlighted blocks using the move command
vim.keymap.set("x", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("x", "K", ":m '<-2<CR>gv=gv")

vim.o.signcolumn = "yes"

vim.o.undofile = true

vim.o.autoread = true

-- one status bar, not sure if I prefer that
vim.o.laststatus = 3

---------------------------------------------------------------
-- .h are C header files, .hpp C++ header files
---------------------------------------------------------------

-- Set filetype of .h files (C header) to 'C' (instead of 'C++')
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.h",
  command = "set filetype=c",
})

---------------------------------------------------------------
-- Splits and Tabbed Files
---------------------------------------------------------------
vim.cmd([[set splitbelow splitright]])

-- Remap splits navigation to just <leader> + arrow keys
vim.keymap.set("n", "<leader><left>", "<C-w>h", { noremap = true })
vim.keymap.set("n", "<leader><down>", "<C-w>j", { noremap = true })
vim.keymap.set("n", "<leader><up>", "<C-w>k", { noremap = true })
vim.keymap.set("n", "<leader><right>", "<C-w>l", { noremap = true })

-- Make adjusting split sizes a bit more friendly
vim.keymap.set("n", "<C-h>", "<cmd>vertical resize +3<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-l>", "<cmd>vertical resize -3<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "<cmd>resize +3<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", "<cmd>resize -3<CR>", { noremap = true, silent = true })

-- Change 2 split windows from vert to horiz or horiz to vert
vim.keymap.set("", "<C-w>v", "<C-w>t<C-w>H")
vim.keymap.set("", "<C-w>h", "<C-w>t<C-w>K")

---------------------------------------------------------------
-- Custom Line Wrapping Behaviour
---------------------------------------------------------------

-- don't wrap to next line by default
vim.opt.wrap = false

local function enable_visual_nav()
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
end

local function disable_visual_nav()
  vim.opt_local.wrap = false
  vim.opt_local.linebreak = false
end

local wrap_fts = {
  text = true, markdown = true, tex = true, plaintex = true, typst = true,
}

local function apply_visual_nav_for_ft()
  local on = wrap_fts[vim.bo.filetype] or false
  vim.b.visual_nav_enabled = on
  if on then enable_visual_nav() else disable_visual_nav() end
end

local function toggle_visual_nav()
  vim.b.visual_nav_enabled = not vim.b.visual_nav_enabled

  if vim.b.visual_nav_enabled then
    enable_visual_nav()
    print("Visual-line navigation ENABLED")
  else
    disable_visual_nav()
    print("Visual-line navigation DISABLED")
  end
end

-- Normal mode movement
vim.keymap.set("n", "j", function()
  return vim.b.visual_nav_enabled and vim.v.count == 0 and "gj" or "j"
end, { expr = true })

vim.keymap.set("n", "k", function()
  return vim.b.visual_nav_enabled and vim.v.count == 0 and "gk" or "k"
end, { expr = true })

vim.keymap.set("n", "0", function()
  return vim.b.visual_nav_enabled and "g0" or "0"
end, { expr = true })

vim.keymap.set("n", "$", function()
  return vim.b.visual_nav_enabled and "g$" or "$"
end, { expr = true })

-- Visual mode movement
vim.keymap.set("x", "j", function()
  return vim.b.visual_nav_enabled and "gj" or "j"
end, { expr = true })

vim.keymap.set("x", "k", function()
  return vim.b.visual_nav_enabled and "gk" or "k"
end, { expr = true })

vim.keymap.set("x", "0", function()
  return vim.b.visual_nav_enabled and "g0" or "0"
end, { expr = true })

vim.keymap.set("x", "$", function()
  return vim.b.visual_nav_enabled and "g$" or "$"
end, { expr = true })

-- Set initial empty buffer to filetype text
vim.api.nvim_create_augroup("InitialEmptyBuffer", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
  group = "InitialEmptyBuffer",
  callback = function()
    if vim.fn.expand("%") == "" and vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
      vim.bo.filetype = "text"
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = apply_visual_nav_for_ft,
})

vim.api.nvim_create_user_command("ToggleVisualNav", toggle_visual_nav, {})

---------------------------------------------------------------
-- Colorscheme
---------------------------------------------------------------

vim.cmd("syntax enable")

vim.o.background = "dark"

local c = {

  -- hard
  -- bg0 = "#1d2021", -- Normal bg
  -- bg1 = "#282828", -- CursorLine

  -- medium
  bg0 = "#282828", -- Normal bg
  bg1 = "#32302f", -- CursorLine
  bg2 = "#3c3836", -- Pmenu
  bg3 = "#504945", -- WinSeparator, borders
  -- two steps above bg2, so a selection still reads over CursorLine and floats
  bg4 = "#665c54", -- Visual

  -- soft
  -- bg0 = "#32302f", -- Normal bg
  -- bg1 = "#3c3836", -- CursorLine
  -- bg2 = "#504945", -- Pmenu
  -- bg3 = "#665c54", -- WinSeparator, borders
  -- bg4 = "#7c6f64", -- Visual

  white = "#ffffff",  -- NOTE
  fg = "#ebdbb2",     -- Normal fg
  grey2 = "#bdae93",  -- delimiters, punctuation
  grey1 = "#a89984",  -- Comment
  grey0 = "#7c6f64",  -- LineNr

  red = "#fb6b5c",    -- Keyword, Statement
  green = "#b8bb26",  -- String, Function
  yellow = "#fabd2f", -- Type
  blue = "#8ec7b8",   -- Identifier
  purple = "#e69bad", -- Constant, Number, Boolean
  aqua = "#8ec07c",   -- PreProc, Operator
  orange = "#fe8019", -- Special
}

local hl = {
  -- editor surfaces
  Normal                = { fg = c.fg, bg = c.bg0 },
  NormalFloat           = { fg = c.fg, bg = c.bg1 },
  CursorLine            = { bg = c.bg1 },
  Visual                = { bg = c.bg4 },
  VisualNOS             = { bg = c.bg4 },
  Pmenu                 = { fg = c.fg, bg = c.bg2 },
  PmenuSel              = { fg = c.bg0, bg = c.blue },
  StatusLine            = { fg = c.fg, bg = c.bg2 },
  WinSeparator          = { fg = c.bg3 },
  SignColumn            = { bg = c.bg0 },
  Folded                = { fg = c.grey1, bg = c.bg1, italic = true },

  -- gutter and cursor
  LineNr                = { fg = c.grey0 },
  CursorLineNr          = { fg = c.yellow },
  MatchParen            = { bg = c.bg3, bold = true },

  -- search
  Search                = { fg = c.bg0, bg = c.yellow },
  IncSearch             = { fg = c.bg0, bg = c.orange },

  -- messages and diagnostics
  ErrorMsg              = { fg = c.red, bold = true },
  WarningMsg            = { fg = c.yellow, bold = true },
  DiagnosticError       = { fg = c.red },
  DiagnosticWarn        = { fg = c.yellow },
  DiagnosticInfo        = { fg = c.blue },
  DiagnosticHint        = { fg = c.aqua },

  -- syntax; treesitter and LSP captures default-link to these
  Comment               = { fg = c.grey1, italic = true },
  SpecialComment        = { fg = c.grey1, italic = true },
  Todo                  = { fg = c.yellow, italic = true },
  Error                 = { fg = c.red },
  ["@comment.todo"]     = { fg = c.yellow, italic = false },
  ["@comment.error"]    = { fg = c.red, italic = false },
  ["@comment.note"]     = { fg = c.white, italic = false },
  -- LSP semantic tokens outrank treesitter (125 vs 100); lua_ls marks whole
  -- comments as "comment", which repaints TODO/FIXME/NOTE grey. Empty table
  -- = paint nothing, so the treesitter captures above survive.
  ["@lsp.type.comment"] = {},
  String                = { fg = c.green },
  Character             = { fg = c.green },
  Function              = { fg = c.green, bold = true },
  Keyword               = { fg = c.red },
  Statement             = { fg = c.red },
  Type                  = { fg = c.yellow },
  Identifier            = { fg = c.blue },
  -- the one capture nvim sets explicitly, so it ignores Identifier
  ["@variable"]         = { fg = c.fg },
  ["@variable.member"]  = { fg = c.blue },
  ["@property"]         = { fg = c.blue },
  Constant              = { fg = c.purple },
  Number                = { fg = c.purple },
  Boolean               = { fg = c.purple },
  PreProc               = { fg = c.aqua },
  Operator              = { fg = c.aqua },
  Special               = { fg = c.orange },
  Delimiter             = { fg = c.grey2 },
}

for group, opts in pairs(hl) do
  vim.api.nvim_set_hl(0, group, opts)
end

-- own groups, so per-language groups like rustTodo/cTodo don't lump them together
vim.api.nvim_set_hl(0, "MyTodo", { fg = c.yellow })
vim.api.nvim_set_hl(0, "MyFixme", { fg = c.red })
vim.api.nvim_set_hl(0, "MyNote", { fg = c.white })

vim.api.nvim_create_autocmd("Syntax", {
  callback = function()
    vim.cmd([[
      syntax keyword MyTodo  TODO XXX          contained containedin=.*Comment.*
      syntax keyword MyFixme FIXME BUG HACK    contained containedin=.*Comment.*
      syntax keyword MyNote  NOTE NB SAFETY    contained containedin=.*Comment.*
    ]])
  end,
})

---------------------------------------------------------------
-- Status Line
---------------------------------------------------------------

-- segment colors, brightest first: accent block, raised block, base bar.
vim.api.nvim_set_hl(0, "StlMode", { fg = c.bg0, bg = c.blue, bold = true })
vim.api.nvim_set_hl(0, "StlGit", { fg = c.yellow, bg = c.bg3 })
vim.api.nvim_set_hl(0, "StlMod", { fg = c.grey2, bg = c.bg1 })
vim.api.nvim_set_hl(0, "StlRO", { fg = c.bg0, bg = c.red, bold = true })

local modes = {
  n = "NORMAL",
  i = "INSERT",
  v = "VISUAL",
  V = "V-LINE",
  ["\22"] = "V-BLOCK",
  c = "COMMAND",
  t = "TERMINAL",
  R = "REPLACE",
  s = "SELECT",
  S = "S-LINE",
  ["\19"] = "S-BLOCK",
}

function _G._statusline()
  local mode = modes[vim.fn.mode()] or vim.fn.mode():upper()
  local branch = vim.b.git_branch and "%#StlGit# " .. vim.b.git_branch .. " %*" or ""
  local path = vim.b.rel_path or "%f"

  -- mod clears itself on write; :w never sets readonly, so RO is unaffected
  local ro = (vim.bo.readonly or not vim.bo.modifiable) and "%#StlRO# RO %*" or ""
  local mod = vim.bo.modified and "%#StlMod# [+] %*" or ""

  local diag = ""
  local counts = vim.diagnostic.count(0) or {}
  local labels = { " ", " ", " ", " " }
  local hls = { "DiagnosticError", "DiagnosticWarn", "DiagnosticInfo", "DiagnosticHint" }
  for i = 1, 4 do
    if counts[i] and counts[i] > 0 then
      diag = diag .. "%#" .. hls[i] .. "#" .. labels[i] .. counts[i] .. "%* "
    end
  end

  return "%#StlMode# " ..
      mode .. " %*" .. ro .. branch .. mod .. " " .. path .. "%=" .. diag .. vim.bo.filetype .. " %l:%c"
end

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("%s+$", "")
    if root ~= "" then
      vim.b.git_branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("%s+$", "")
      vim.b.rel_path = vim.fn.expand("%:p"):sub(#root + 2)
    else
      vim.b.git_branch = nil
      vim.b.rel_path = vim.fn.expand("%:p:~")
    end
  end,
})

-- diagnostics arrive async, 'modified' flips mid-insert, and 'readonly'
-- changes only via :set; none of them redraw the bar on their own
local function redraw()
  vim.cmd("redrawstatus!")
end

vim.api.nvim_create_autocmd({ "DiagnosticChanged", "BufModifiedSet" }, { callback = redraw })
vim.api.nvim_create_autocmd("OptionSet", { pattern = { "readonly", "modifiable" }, callback = redraw })

vim.o.statusline = "%!v:lua._statusline()"

---------------------------------------------------------------
-- Plugins
---------------------------------------------------------------

-- post-install/update hooks; must exist before vim.pack.add to catch the first install
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    -- tree-sitter-yaml ships only C sources: build parser/yaml.so and put the
    -- highlights where nvim looks for them, both found via the rtp
    if name == 'tree-sitter-yaml' and (kind == 'install' or kind == 'update') then
      local dir = ev.data.path
      vim.fn.mkdir(dir .. '/parser', 'p')
      vim.fn.mkdir(dir .. '/queries/yaml', 'p')
      vim.uv.fs_copyfile(dir .. '/queries/highlights.scm', dir .. '/queries/yaml/highlights.scm')
      vim.system({
        'cc', '-o', dir .. '/parser/yaml.so', '-shared', '-fPIC', '-O2', '-I', dir .. '/src',
        dir .. '/src/parser.c', dir .. '/src/scanner.c',
      }):wait()
    end
  end,
})

-- install plugins
vim.pack.add({
  -- dependency for oil
  'https://github.com/nvim-tree/nvim-web-devicons',

  -- file explorer
  'https://github.com/stevearc/oil.nvim',

  -- git stuff
  'https://github.com/lewis6991/gitsigns.nvim',

  -- find files/live grep
  'https://github.com/nvim-mini/mini.pick',

  -- lsp configurations
  'https://github.com/neovim/nvim-lspconfig',

  'https://github.com/tpope/vim-surround',

  -- markdown rendering (uses nvim's bundled markdown parser, no nvim-treesitter)
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',

  -- yaml parser for render-markdown's front matter (nvim bundles no yaml parser)
  'https://github.com/tree-sitter-grammars/tree-sitter-yaml',

})

---------------------------------------------------------------
-- LSP
---------------------------------------------------------------

vim.o.autocomplete = true
vim.o.completeopt = 'menu,menuone,noselect,popup'
vim.o.complete = 'o,.,w,b,u'
vim.o.pumborder = 'rounded' -- optional
vim.o.pummaxwidth = 40      -- optional

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, {
        -- strip clangd's header-insertion decorator from the displayed label
        convert = function(item)
          local detail = vim.tbl_get(item, 'labelDetails', 'detail') or ''
          return { abbr = item.label:gsub('^%s+', ''):gsub('^•%s*', '') .. detail }
        end,
        -- LSP items before buffer words; LSP items among themselves by sortText
        cmp = function(a, b)
          local ia = vim.tbl_get(a, 'user_data', 'nvim', 'lsp', 'completion_item')
          local ib = vim.tbl_get(b, 'user_data', 'nvim', 'lsp', 'completion_item')
          if (ia == nil) ~= (ib == nil) then return ib == nil end
          if ia == nil then return false end
          return (ia.sortText or ia.label) < (ib.sortText or ib.label)
        end,
      })
    end
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
    vim.keymap.set("n", "ga", vim.lsp.buf.code_action, { buffer = ev.buf })
  end,
})

-- diagnostics
vim.keymap.set("n", "<leader>E", function()
  vim.diagnostic.open_float(nil, { focus = false })
end, { desc = "Show diagnostics under cursor" })


local function pum(yes, no)
  return function() return vim.fn.pumvisible() == 1 and yes or no end
end

vim.keymap.set("i", "<Tab>", pum("<C-n>", "<Tab>"), { expr = true })
vim.keymap.set("i", "<S-Tab>", pum("<C-p>", "<S-Tab>"), { expr = true })
vim.keymap.set("i", "<CR>", pum("<C-y>", "<CR>"), { expr = true })

-- snippet jumps (native expansion uses vim.snippet, not luasnip)
vim.keymap.set({ "i", "s" }, "<C-l>", function()
  return vim.snippet.active({ direction = 1 }) and "<Cmd>lua vim.snippet.jump(1)<CR>" or "<C-l>"
end, { expr = true })
vim.keymap.set({ "i", "s" }, "<C-h>", function()
  return vim.snippet.active({ direction = -1 }) and "<Cmd>lua vim.snippet.jump(-1)<CR>" or "<C-h>"
end, { expr = true })


local sev = vim.diagnostic.severity
vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  virtual_text = { current_line = true },
  float = { border = 'rounded', source = true },
  signs = { text = { [sev.ERROR] = 'E', [sev.WARN] = 'W', [sev.INFO] = 'I', [sev.HINT] = 'H' } },
})

-- Diagnostics list, in place of `Telescope diagnostics`: every loaded buffer's
-- diagnostics in a mini.pick window, worst first. Items carry bufnr/lnum/col,
-- which is all mini.pick's default preview and choose need to jump to them.
local diag_labels = { [sev.ERROR] = 'E', [sev.WARN] = 'W', [sev.INFO] = 'I', [sev.HINT] = 'H' }

local function pick_diagnostics()
  local diags = vim.diagnostic.get()
  table.sort(diags, function(a, b)
    if a.severity ~= b.severity then return a.severity < b.severity end
    if a.bufnr ~= b.bufnr then return a.bufnr < b.bufnr end
    if a.lnum ~= b.lnum then return a.lnum < b.lnum end
    return a.col < b.col
  end)

  local items = vim.tbl_map(function(d)
    local name = vim.api.nvim_buf_get_name(d.bufnr)
    local path = name ~= '' and vim.fn.fnamemodify(name, ':.') or ('[No Name %d]'):format(d.bufnr)
    -- multi-line messages (rustc, clangd) would break the one-line-per-item list
    local msg = d.message:gsub('%s*\n%s*', ' ')
    return {
      text = ('%s %s:%d:%d %s'):format(diag_labels[d.severity] or '?', path, d.lnum + 1, d.col + 1, msg),
      bufnr = d.bufnr,
      lnum = d.lnum + 1,
      col = d.col + 1,
    }
  end, diags)

  if #items == 0 then
    return vim.notify('No diagnostics', vim.log.levels.INFO)
  end
  MiniPick.start({ source = { items = items, name = 'Diagnostics' } })
end

vim.keymap.set('n', '<leader>dl', pick_diagnostics, { desc = 'List diagnostics' })

vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function(ev)
    if #vim.lsp.get_clients({ bufnr = ev.buf, method = 'textDocument/formatting' }) > 0 then
      vim.lsp.buf.format({ bufnr = ev.buf, timeout_ms = 2000 })
    end
  end,
})

-- neovim-lua support
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = {
        checkThirdParty = false,
        -- every lua/ dir on the rtp: nvim's own meta files plus the plugins
        -- added by vim.pack, so require('oil') & co. get types too
        library = vim.api.nvim_get_runtime_file('lua', true),
      },
    },
  },
})

vim.lsp.config('clangd', { cmd = { 'clangd', '--header-insertion-decorators=0' } })

local servers = { "lua_ls", "clangd", "rust_analyzer", "pyright", "bashls", "cmake" }

vim.lsp.enable(vim.tbl_filter(function(name)
  local cfg = vim.lsp.config[name]
  local cmd = cfg and cfg.cmd
  -- a few configs use a function for cmd (in-process servers); nothing to look up on PATH
  if type(cmd) == "table" then return vim.fn.executable(cmd[1]) == 1 end
  return cmd ~= nil
end, servers))

---------------------------------------------------------------
-- File Explorer
---------------------------------------------------------------

require('oil').setup()

vim.keymap.set('n', '<leader>e', '<cmd>Oil<cr>', { desc = 'Open parent directory' })

---------------------------------------------------------------
-- File Picker
---------------------------------------------------------------

require('mini.pick').setup({
  window = {
    config = function()
      local height = math.floor(0.618 * vim.o.lines)
      local width = math.floor(0.618 * vim.o.columns)
      return {
        anchor = 'NW',
        height = height,
        width = width,
        row = math.floor(0.5 * (vim.o.lines - height)),
        col = math.floor(0.5 * (vim.o.columns - width)),
        border = 'rounded',
      }
    end,
    -- prompt_prefix = '  ',
  },
})

-- make mini less visually cluttered
vim.api.nvim_set_hl(0, 'MiniPickNormal', { link = 'Normal' })             -- kills the float "box"
vim.api.nvim_set_hl(0, 'MiniPickBorder', { link = 'Comment' })            -- quiet border, not accent-coloured
vim.api.nvim_set_hl(0, 'MiniPickBorderBusy', { link = 'MiniPickBorder' }) -- stop the warn-colour flash
vim.api.nvim_set_hl(0, 'MiniPickBorderText', { link = 'Comment' })
vim.api.nvim_set_hl(0, 'MiniPickPrompt', { link = 'Normal' })             -- no diagnostic blue
vim.api.nvim_set_hl(0, 'MiniPickHeader', { link = 'Comment' })
vim.api.nvim_set_hl(0, 'MiniPickMatchRanges', { link = 'Special' })       -- one accent, for matched chars only

-- vim.api.nvim_set_hl(0, 'MiniPickBorder',       { link = 'FloatBorder' })
-- vim.api.nvim_set_hl(0, 'MiniPickMatchCurrent', { link = 'CursorLine' })

vim.keymap.set('n', '<C-p>', MiniPick.builtin.files, { desc = 'Find files' })
vim.keymap.set('n', '<C-s>', MiniPick.builtin.grep_live, { desc = 'Live grep' })

---------------------------------------------------------------
-- Git
---------------------------------------------------------------

require("gitsigns").setup({})

vim.keymap.set("n", "<leader>gd", "<cmd>Gitsigns diffthis<cr>", { desc = "Diff current file against index" })
vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns blame<cr>", { desc = "Blame current file in split" })
vim.keymap.set("n", "<leader>ga", "<cmd>Gitsigns stage_buffer<cr>", { desc = "Stage current buffer?" })
vim.keymap.set("v", "<leader>ga", "<cmd>Gitsigns stage_hunk<cr>",
  { desc = "Stage hunk under cursor/selected in virtual mode" })
