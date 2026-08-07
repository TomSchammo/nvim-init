---------------------------------------------------------------
-- General settings
---------------------------------------------------------------

-- set proper language (UTF-8 clipboard supoort)
vim.cmd("lang en_US.UTF-8")

-- setting tab size and so on
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- auto indent
vim.opt.smartindent = true

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
vim.keymap.set("v", "<leader>y", '"+y', { noremap = true })

-- move highlighted blocks using the move command
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.o.signcolumn = "yes"

vim.o.undofile = true

vim.o.autoread = true

-- one status bar, not sure if I prefer that
vim.o.laststatus = 3


---------------------------------------------------------------
-- LSP
---------------------------------------------------------------

vim.pack.add {
  { src = 'https://github.com/neovim/nvim-lspconfig' },
}

vim.o.autocomplete = true
vim.o.completeopt = 'menu,menuone,noselect,popup'
vim.o.pumborder = 'rounded' -- optional
vim.o.pummaxwidth = 40      -- optional

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

-- diagnostics
vim.diagnostic.config({ virtual_text = true })
vim.keymap.set("n", "<leader>E", "<cmd>lua vim.diagnostic.open_float(nil, {focus=false})<cr>", { buffer = bufnr })


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

vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function(ev)
    vim.lsp.buf.format({ bufnr = ev.buf, timeout_ms = 2000 })
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

vim.lsp.enable({ "lua_ls", "clangd", "rust_analyzer" })

---------------------------------------------------------------
-- Colorscheme
---------------------------------------------------------------

vim.o.background = "dark"

local c = {

  -- hard
  -- bg0 = "#1d2021", -- Normal bg
  -- bg1 = "#282828", -- CursorLine

  -- medium
  bg0 = "#282828", -- Normal bg
  bg1 = "#32302f", -- CursorLine
  bg2 = "#3c3836", -- Visual, Pmenu
  bg3 = "#504945", -- WinSeparator, borders

  -- soft
  -- bg0 = "#32302f", -- Normal bg
  -- bg1 = "#3c3836", -- CursorLine
  -- bg2 = "#504945", -- Visual, Pmenu
  -- bg3 = "#665c54", -- WinSeparator, borders

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
  Normal = { fg = c.fg, bg = c.bg0 },
  NormalFloat = { fg = c.fg, bg = c.bg1 },
  CursorLine = { bg = c.bg1 },
  Visual = { bg = c.bg2 },
  Pmenu = { fg = c.fg, bg = c.bg2 },
  PmenuSel = { fg = c.bg0, bg = c.blue },
  StatusLine = { fg = c.fg, bg = c.bg2 },
  WinSeparator = { fg = c.bg3 },
  SignColumn = { bg = c.bg0 },
  Folded = { fg = c.grey1, bg = c.bg1, italic = true },

  -- gutter and cursor
  LineNr = { fg = c.grey0 },
  CursorLineNr = { fg = c.yellow },
  MatchParen = { bg = c.bg3, bold = true },

  -- search
  Search = { fg = c.bg0, bg = c.yellow },
  IncSearch = { fg = c.bg0, bg = c.orange },

  -- messages and diagnostics
  ErrorMsg = { fg = c.red, bold = true },
  WarningMsg = { fg = c.yellow, bold = true },
  DiagnosticError = { fg = c.red },
  DiagnosticWarn = { fg = c.yellow },
  DiagnosticInfo = { fg = c.blue },
  DiagnosticHint = { fg = c.aqua },

  -- syntax; treesitter and LSP captures default-link to these
  Comment = { fg = c.grey1, italic = true },
  Todo = { fg = c.yellow, italic = true },
  Error = { fg = c.red },
  ["@comment.todo"] = { fg = c.yellow, italic = false },
  ["@comment.error"] = { fg = c.red, italic = false },
  ["@comment.note"] = { fg = c.white, italic = false },
  -- LSP semantic tokens outrank treesitter (125 vs 100); lua_ls marks whole
  -- comments as "comment", which repaints TODO/FIXME/NOTE grey. Empty table
  -- = paint nothing, so the treesitter captures above survive.
  ["@lsp.type.comment"] = {},
  String = { fg = c.green },
  Character = { fg = c.green },
  Function = { fg = c.green, bold = true },
  Keyword = { fg = c.red },
  Statement = { fg = c.red },
  Type = { fg = c.yellow },
  Identifier = { fg = c.blue },
  -- the one capture nvim sets explicitly, so it ignores Identifier
  ["@variable"] = { fg = c.fg },
  Constant = { fg = c.purple },
  Number = { fg = c.purple },
  Boolean = { fg = c.purple },
  PreProc = { fg = c.aqua },
  Operator = { fg = c.aqua },
  Special = { fg = c.orange },
  Delimiter = { fg = c.grey2 },
}

for group, opts in pairs(hl) do
  vim.api.nvim_set_hl(0, group, opts)
end

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
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize +3<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize -3<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-Up>", "<cmd>resize +3<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -3<CR>", { noremap = true, silent = true })

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

local function apply_visual_nav_for_ft()
  local ft = vim.bo.filetype
  if ft == "text" or ft == "markdown" or ft == "tex" or ft == "typst" then
    enable_visual_nav()
  else
    disable_visual_nav()
  end
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

-- Enable for specific filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "plaintex", "tex", "text", "typst" },
  callback = function()
    vim.b.visual_nav_enabled = true
    enable_visual_nav()
  end,
})

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
-- Plugins
---------------------------------------------------------------

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
})

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
vim.keymap.set("v", "<leader>gp", "<cmd>Gitsigns stage_hunk<cr>",
  { desc = "Stage hunk under cursor/selected in virtual mode" })
