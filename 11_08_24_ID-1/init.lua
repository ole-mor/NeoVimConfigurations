-- Settings
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.mouse = "a"
vim.opt.showmatch = true
vim.opt.swapfile = false
vim.opt.fillchars = { eob = ' ' }
vim.opt.wrap = false
vim.cmd('syntax on')
vim.cmd('colorscheme slate')

-- Manager Setup (using packer.nvim as an example)
-- Ensure packer is installed
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'folke/tokyonight.nvim'
  use 'kyazdani42/nvim-tree.lua'
  use 'nvim-lualine/lualine.nvim'
  use { 'junegunn/fzf', run = fn['fzf#install'] }
  use 'junegunn/fzf.vim'
  use 'tpope/vim-fugitive'
  use { 'neoclide/coc.nvim', branch = 'release' }
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'nvim-tree/nvim-web-devicons'
  use 'petertriho/nvim-scrollbar'
  use 'karb94/neoscroll.nvim'
  use 'nvim-lua/plenary.nvim'
  use {
      'nvim-telescope/telescope.nvim', tag = '0.1.8',
      requires = { {'nvim-lua/plenary.nvim'} }
  }
  use {
      'goolord/alpha-nvim',
      requires = { 'nvim-tree/nvim-web-devicons' }, -- for file icons
      config = function()
          require'alpha'.setup(require'alpha.themes.startify'.config)
      end
  } 
  -- Automatically set up your configuration after cloning packer.nvim
  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- Key Mappings
vim.api.nvim_set_keymap('n', '<Space>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '..', ':lua FocusOrOpenNvimTree()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-p>', ':Files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-f>', ':Rg<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gs', ':G<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gc', ':G commit<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gp', ':G push<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>n', ':call CreateNewFile()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', { expr = true, noremap = true })
vim.api.nvim_set_keymap('i', '<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<S-Tab>"', { expr = true, noremap = true })
vim.api.nvim_set_keymap('n', '<Space>f', [[:lua vim.fn.setreg('/', '\\<' .. vim.fn.expand('<cword>') .. '\\>')<CR>cgn]], { noremap = true, silent = true })

-- Mapping for opening terminal with 't!'
vim.api.nvim_set_keymap('n', 't!', ':lua OpenStyledTerminal()<CR>', { noremap = true, silent = true })

-- Lua function to open a styled terminal
function OpenStyledTerminal()
  -- Open a terminal in a new split
  vim.cmd('split | terminal')
  -- Set options for the terminal window
  vim.cmd('setlocal nonumber norelativenumber')
  -- Start insert mode in the terminal
  vim.cmd('startinsert')
end

-- lualine Configuration
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = {'|','|'},
    section_separators = {'', ''},
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}

-- fzf Command Prefix
vim.g.fzf_command_prefix = 'Fzf'

-- coc.nvim Extensions
vim.g.coc_global_extensions = {'coc-json', 'coc-tsserver', 'coc-html', 'coc-css'}

vim.cmd [[highlight AlphaHeader guifg=#8B0000 guibg=#000000]]
local alpha = require'alpha'
local startify = require'alpha.themes.startify'

-- Set the width to match your average terminal window width
local width = 80
local function center_pad(str)
  local padding = math.floor((width - #str) / 2)
  return string.rep(" ", padding) .. str
end

startify.section.header.val = {
                                                                         
    "⠁⡼⠋⠀⣆⠀⠀⣰⣿⣫⣾⢿⣿⣿⠍⢠⠠⠀⠀⢀⠰⢾⣺⣻⣿⣿⣿⣷⡀⠀",
    "⣥⠀⠀⠀⠁⠀⠠⢻⢬⠁⣠⣾⠛⠁⠀⠀⠀⠀⠀⠀⠀⠐⠱⠏⡉⠙⣿⣿⡇⠀",
    "⢳⠀⢰⡖⠀⠀⠈⠀⣺⢰⣿⢻⣾⣶⣿⣿⣶⣶⣤⣤⣴⣾⣿⣷⣼⡆⢸⣿⣧⠀",
    "⠈⠀⠜⠈⣀⣔⣦⢨⣿⣿⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣅⣼⠛⢹⠀",
    "⠀⠀⠀⠀⢋⡿⡿⣯⣭⡟⣟⣿⣿⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⡘⠀",
    "⡀⠐⠀⠀⠀⣿⣯⡿⣿⣿⣿⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⣉⢽⣿⡆⠀⠀",
    "⢳⠀⠄⠀⢀⣿⣿⣿⣿⣿⣿⣿⠙⠉⠉⠉⠛⣻⢛⣿⠛⠃⠀⠐⠛⠻⣿⡇⠀⠀",
    "⣾⠄⠀⠀⢸⣿⣿⡿⠟⠛⠁⢀⠀⢀⡄⣀⣠⣾⣿⣿⡠⣴⣎⣀⣠⣠⣿⡇⠀⠀",
    "⣧⠀⣴⣄⣽⣿⣿⣿⣶⣶⣖⣶⣬⣾⣿⣾⣿⣿⣿⣿⣽⣿⣿⣿⣿⣿⣿⡇⠀⠀",
    "⣿⣶⣈⡯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⣹⢧⣿⣿⣿⣄⠙⢿⣿⣿⣿⠇⠀⠀",
    "⠹⣿⣿⣧⢌⢽⣻⢿⣯⣿⣿⣿⣿⠟⣠⡘⠿⠟⠛⠛⠟⠛⣧⡈⠻⣾⣿⠀⠀⠀",
    "⠀⠈⠉⣷⡿⣽⠶⡾⢿⣿⣿⣿⢃⣤⣿⣷⣤⣤⣄⣄⣠⣼⡿⢷⢀⣿⡏⠀⠀⠀",
    "⠀⠀⢀⣿⣷⠌⣈⣏⣝⠽⡿⣷⣾⣏⣀⣉⣉⣀⣀⣀⣠⣠⣄⡸⣾⣿⠃⠀⠀⠀",
    "⠀⣰⡿⣿⣧⡐⠄⠱⣿⣺⣽⢟⣿⣿⢿⣿⣍⠉⢀⣀⣐⣼⣯⡗⠟⡏⠀⠀⠀⠀",
    "⣰⣿⠀⣿⣿⣴⡀⠂⠘⢹⣭⡂⡚⠿⢿⣿⣿⣿⡿⢿⢿⡿⠿⢁⣴⣿⣷⣶⣦⣤",
    "                              ",

    
    "-It's fucking raw"

}
startify.section.header.opts = { position = "center", hl = "AlphaHeader" }
alpha.setup(startify.config)


-- nvim-treesitter Configuration
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "lua", "python", "javascript" },
  highlight = {
    enable = true,
  },
}

-- nvim-tree Configuration
local function on_attach(bufnr)
  local api = require('nvim-tree.api')

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- Enable default mappings
  api.config.mappings.default_on_attach(bufnr)

  -- Allow opening files and folders
  vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Edit'))
  vim.keymap.set('n', 'o', api.node.open.edit, opts('Edit'))
  vim.keymap.set('n', '<2-LeftMouse>', api.node.open.edit, opts('Edit'))

  -- Allow creating new files and folders with 'a'
  vim.keymap.set('n', 'a', api.fs.create, opts('Create'))

  -- Disable other actions that should not be available
  vim.keymap.set('n', 'h', '', opts('Disable h'))
  vim.keymap.set('n', 'l', '', opts('Disable l'))
  vim.keymap.set('n', 'v', '', opts('Disable v'))
  vim.keymap.set('n', 's', '', opts('Disable s'))
  vim.keymap.set('n', 'i', '', opts('Disable i'))

  -- Set custom mapping for toggle action
  vim.keymap.set('n', '<C-t>', api.tree.toggle, opts('Toggle Tree'))
end

require('nvim-tree').setup {
  view = {
    width = 30,
    side = 'left',
  },
  update_cwd = true,
  update_focused_file = {
    enable = true,
    update_cwd = true,
  },
  renderer = {
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
    },
  },
  on_attach = on_attach,
}

-- Lua function to focus on or open nvim-tree
function FocusOrOpenNvimTree()
  local view = require('nvim-tree.view')
  local api = require('nvim-tree.api')
  if view.is_visible() then
    -- If nvim-tree is visible, focus on it
    vim.cmd('wincmd p')
  else
    -- If nvim-tree is not visible, open it
    api.tree.open()
  end
end

-- Function to Create New File
function CreateNewFile()
  local filename = vim.fn.input("Enter new file name: ")
  if filename and filename ~= '' then
    vim.cmd('edit ' .. filename)
    vim.cmd('w')
    require'nvim-tree'.refresh()
  end
end

-- Scrollbar and Neoscroll Configuration
require("scrollbar").setup()
require('neoscroll').setup()

