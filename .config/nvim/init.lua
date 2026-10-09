require('mini.deps').setup()
-- 配置 icons
local MiniIcons = require('mini.icons')
MiniIcons.setup()
MiniIcons.mock_nvim_web_devicons()

local add = require('mini.deps').add

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.clipboard = 'unnamedplus'  -- 使用系统剪切板
vim.g.mapleader = ' '

add({ source = "catppuccin/nvim", name = "catppuccin" })
vim.cmd.colorscheme "catppuccin-mocha"

-- 模糊查找
add({
  source = 'nvim-telescope/telescope.nvim',
  depends = { 'nvim-lua/plenary.nvim' },
})

-- 自动补全
add({
  source = 'hrsh7th/nvim-cmp',
  depends = {
    'hrsh7th/cmp-nvim-lsp',
    'L3MON4D3/LuaSnip',
  },
})

-- Git 集成
add('lewis6991/gitsigns.nvim')

-- Buffer 标签栏
add({
  source = 'akinsho/bufferline.nvim',
  depends = { 'nvim-tree/nvim-web-devicons' },
})

-- 命令行/消息/弹出菜单美化
add({
  source = 'folke/noice.nvim',
  depends = {
    'MunifTanjim/nui.nvim',    -- 必须依赖
    'rcarriga/nvim-notify',    -- 可选：通知美化
  },
})

-- ========== bufferline.nvim 配置 ==========
require('bufferline').setup({
  options = {
    mode = 'buffers',
    separator_style = 'thin',
    always_show_bufferline = false,  -- 只有一个 buffer 时隐藏
    close_command = 'bdelete! %d',
    buffer_close_icon = '✕',
    modified_icon = '●',
    show_close_icon = false,
    show_buffer_close_icons = true,
    diagnostics = 'nvim_lsp',
    diagnostics_indicator = function(count, level)
      local icon = level:match('error') and ' ' or ' '
      return icon .. count
    end,
    offsets = {
      { filetype = 'NvimTree', text = 'File Explorer', text_align = 'center', separator = true },
    },
  },
})

-- Buffer 切换快捷键
vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>', { silent = true, desc = 'Next buffer' })
vim.keymap.set('n', '<S-Tab>', ':BufferLineCyclePrev<CR>', { silent = true, desc = 'Prev buffer' })
vim.keymap.set('n', '<leader>x', ':bdelete<CR>', { silent = true, desc = 'Close buffer' })

-- lualine.nvim 状态栏
add({
  source = 'nvim-lualine/lualine.nvim',
  depends = { 'nvim-tree/nvim-web-devicons' },
})

-- ========== mini.nvim 模块 ==========
require('mini.ai').setup()        -- 扩展文本对象
require('mini.surround').setup()  -- 环绕操作
require('mini.pairs').setup()     -- 自动括号
require('mini.comment').setup()   -- 注释
require('mini.cursorword').setup() -- 高亮当前单词
require('mini.indentscope').setup() -- 缩进线

-- ========== noice.nvim 配置 ==========
require('noice').setup({
  cmdline = {
    enabled = true,
    view = 'cmdline_popup',  -- 命令行显示为弹出窗口
    opts = {},
  },
  messages = {
    enabled = true,
    view = 'notify',         -- 消息使用 notify 显示
    view_error = 'notify',
    view_warn = 'notify',
    view_history = 'messages',
    view_search = 'virtualtext',
  },
  popupmenu = {
    enabled = true,
    backend = 'nui',         -- 使用 nui 的弹出菜单
  },
  notify = {
    enabled = true,
    view = 'notify',
  },
  lsp = {
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
      ['cmp.entry.get_documentation'] = true,
    },
    hover = { enabled = true },
    signature = { enabled = true },
  },
  presets = {
    bottom_search = false,    -- 搜索不显示在底部
    command_palette = true,   -- 命令行和弹出菜单组合
    long_message_to_split = true,
    inc_rename = false,
    lsp_doc_border = false,
  },
})

-- ========== lualine.nvim 配置 ==========
-- 自定义组件：显示 LSP 服务器
local function lsp_clients()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then return '' end
  local names = {}
  for _, client in ipairs(clients) do
    table.insert(names, client.name)
  end
  return ' ' .. table.concat(names, ', ')
end

-- 自定义组件：显示宏录制状态
local function macro_recording()
  local reg = vim.fn.reg_recording()
  if reg ~= '' then
    return ' @' .. reg
  end
  return ''
end

-- 自定义组件：文件大小
local function file_size()
  local size = vim.fn.getfsize(vim.fn.expand('%:p'))
  if size < 0 then return '' end
  if size < 1024 then
    return size .. 'B'
  elseif size < 1024 * 1024 then
    return string.format('%.1fK', size / 1024)
  else
    return string.format('%.1fM', size / (1024 * 1024))
  end
end

require('lualine').setup({
  options = {
    theme = 'catppuccin',
    component_separators = { left = '│', right = '│' },
    section_separators = { left = '', right = '' },
    globalstatus = true,
    disabled_filetypes = { statusline = { 'dashboard', 'alpha', 'starter' } },
  },
  sections = {
    lualine_a = {
      { 'mode', fmt = function(s) return s:sub(1, 1) end },  -- 只显示首字母 N/I/V
    },
    lualine_b = {
      { 'branch', icon = '' },
      { 'diff', symbols = { added = ' ', modified = ' ', removed = ' ' } },
      { 'diagnostics', sources = { 'nvim_diagnostic' } },
    },
    lualine_c = {
      { macro_recording, color = { fg = '#ff9e64' } },
      { 'filename', path = 1, symbols = { modified = '●', readonly = '', unnamed = '󰡯' } },
    },
    lualine_x = {
      { lsp_clients, cond = function() return #vim.lsp.get_clients({ bufnr = 0 }) > 0 end },
      { 'filetype', icon_only = true },
      { 'encoding', show_bomb = true, fmt = function(s) return s:lower() end },
      { 'fileformat', symbols = { unix = 'LF', dos = 'CRLF', mac = 'CR' } },
    },
    lualine_y = {
      { file_size, cond = function() return vim.fn.empty(vim.fn.expand('%:t')) == 0 end },
      { 'progress', separator = ' ', padding = { left = 1, right = 0 } },
    },
    lualine_z = {
      { 'location', separator = ' ', padding = { left = 0, right = 1 } },
      { 'selectioncount', cond = function() return vim.fn.mode():find('[vV]') ~= nil end },
      { 'searchcount', cond = function() return vim.v.hlsearch == 1 end },
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { { 'filename', path = 1 } },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = { 'quickfix', 'lazy' },
})
