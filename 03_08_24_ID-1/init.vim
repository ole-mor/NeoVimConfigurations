" General Settings
set number
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set mouse=a
set showmatch
set noswapfile
set fillchars=eob:\ 
set nowrap
syntax on
colorscheme slate

" Plugin Manager Setup
call plug#begin('~/.vim/plugged')
Plug 'folke/tokyonight.nvim'
Plug 'kyazdani42/nvim-tree.lua'
Plug 'nvim-lualine/lualine.nvim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-tree/nvim-web-devicons'
Plug 'petertriho/nvim-scrollbar'
Plug 'karb94/neoscroll.nvim'
call plug#end()

" Key Mappings
nnoremap <C-t> :NvimTreeToggle<CR>
nnoremap .. :lua FocusOrOpenNvimTree()<CR>
nnoremap <silent> <C-p> :Files<CR>
nnoremap <silent> <C-f> :Rg<CR>
nnoremap <leader>gs :G<CR>
nnoremap <leader>gc :G commit<CR>
nnoremap <leader>gp :G push<CR>
nnoremap <silent> <leader>n :call CreateNewFile()<CR>
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Mapping for opening terminal with 't!'
nnoremap t! :call OpenStyledTerminal()<CR>

" Function to open a styled terminal
function! OpenStyledTerminal(...)
  " Open a terminal in a new split
  execute 'terminal'
  " Set options for the terminal window
  setlocal nonumber norelativenumber
  " Start insert mode in the terminal
  startinsert
endfunction

" lualine Configuration
lua <<EOF
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
EOF

" fzf Command Prefix
let g:fzf_command_prefix = 'Fzf'

" coc.nvim Extensions
let g:coc_global_extensions = ['coc-json', 'coc-tsserver', 'coc-html', 'coc-css']

" nvim-treesitter Configuration
lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "lua", "python", "javascript" },
  highlight = {
    enable = true,
  },
}
EOF

" nvim-tree Configuration
lua <<EOF
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
EOF

" Lua function to focus on or open nvim-tree
lua <<EOF
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
EOF

" Function to Create New File
function! CreateNewFile()
  let l:filename = input("Enter new file name: ")
  if !empty(l:filename)
    execute "edit " . l:filename
    execute "w"
    lua require'nvim-tree'.refresh()
  endif
endfunction

" Scrollbar and Neoscroll Configuration
lua <<EOF
require("scrollbar").setup()
require('neoscroll').setup()
EOF

