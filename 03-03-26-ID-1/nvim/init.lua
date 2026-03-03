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
-- Theme Configuration
require("tokyonight").setup({
  transparent = true, -- Enable tokyonight's native transparency
  styles = {
    sidebars = "transparent", -- Explicitly make sidebars transparent
    floats = "transparent",
  },
})
vim.cmd('colorscheme tokyonight')

-- Transparent background overrides (Safety for all themes)
vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE', ctermbg = 'NONE' })
vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'NONE', ctermbg = 'NONE' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE', ctermbg = 'NONE' })
vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'NONE', ctermbg = 'NONE' })
vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'NONE', ctermbg = 'NONE' })

-- Nvim-Tree Transparency
vim.api.nvim_set_hl(0, 'NvimTreeNormal', { bg = 'NONE', ctermbg = 'NONE' })
vim.api.nvim_set_hl(0, 'NvimTreeNormalNC', { bg = 'NONE', ctermbg = 'NONE' })
vim.api.nvim_set_hl(0, 'NvimTreeWinSeparator', { bg = 'NONE', ctermbg = 'NONE' })
vim.api.nvim_set_hl(0, 'NvimTreeEndOfBuffer', { bg = 'NONE', ctermbg = 'NONE' })

-- Cursor highlighting
vim.opt.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver25-Cursor,r-cr:hor20-Cursor"
vim.api.nvim_set_hl(0, 'Cursor', { fg = '#000000', bg = '#FFFFFF' })

-- Plugin Manager Setup (lazy.nvim)
-- packer.nvim is archived/unmaintained — using lazy.nvim instead
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  'folke/tokyonight.nvim',
  -- kyazdani42/nvim-tree.lua was renamed to nvim-tree/nvim-tree.lua
  'nvim-tree/nvim-tree.lua',
  'nvim-lualine/lualine.nvim',
  { 'junegunn/fzf', build = function() vim.fn['fzf#install']() end },
  'junegunn/fzf.vim',
  'tpope/vim-fugitive',
  { 'neoclide/coc.nvim', branch = 'release' },
  -- nvim-treesitter: use 'main' branch (master is archived)
  { 'nvim-treesitter/nvim-treesitter', branch = 'main', build = ':TSUpdate' },
  'nvim-tree/nvim-web-devicons',
  'petertriho/nvim-scrollbar',
  'karb94/neoscroll.nvim',
  'nvim-lua/plenary.nvim',
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  {
    'goolord/alpha-nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require'alpha'.setup(require'alpha.themes.startify'.config)
    end,
  },
  {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("render-markdown").setup()
  end,
  },
  {
  "stevearc/overseer.nvim",
  config = function()
    require("overseer").setup({
        -- Add hr_timer component to all tasks via the default alias
        component_aliases = {
          default = {
            "on_exit_set_status",
            "on_complete_notify",
            { "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
            "hr_timer",
          },
        },
        task_list = {
            open_on_start = true,
            direction = "bottom",
            min_height = 20,
            render = function(task)
              local render = require("overseer.render")
              local ret = {
                render.status_and_name(task),
              }
              vim.list_extend(ret, render.source_lines(task))
              -- Precise duration using high-res timer from hr_timer component
              local duration_chunks = {}
              local hr = (_G._overseer_hr_times or {})[task.id]
              if hr and hr.start then
                local elapsed_ns
                if hr.stop then
                  elapsed_ns = hr.stop - hr.start
                else
                  elapsed_ns = vim.uv.hrtime() - hr.start
                end
                local elapsed_s = elapsed_ns / 1e9
                local dur_str
                if elapsed_s < 60 then
                  dur_str = string.format("%.4fs", elapsed_s)
                elseif elapsed_s < 3600 then
                  dur_str = string.format("%dm %.2fs", math.floor(elapsed_s / 60), elapsed_s % 60)
                else
                  dur_str = string.format("%dh %dm %.1fs", math.floor(elapsed_s / 3600), math.floor((elapsed_s % 3600) / 60), elapsed_s % 60)
                end
                duration_chunks = { { dur_str } }
              end
              table.insert(ret, render.join(duration_chunks, render.time_since_completed(task, { hl_group = "Comment" })))
              vim.list_extend(ret, render.result_lines(task, { oneline = true }))
              vim.list_extend(ret, render.output_lines(task, { num_lines = 1 }))
              return render.remove_empty_lines(ret)
            end,
        },
    })
  end,
  },
  {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("bufferline").setup({
      options = {
        mode = "tabs",
        separator_style = "slant",
        show_buffer_close_icons = true,
        show_close_icon = false,
        color_icons = true,
        offsets = {
          {
            filetype = "NvimTree",
            text = "Files",
            highlight = "Directory",
            separator = true,
          }
        },
        custom_filter = function(buf_number)
          if vim.bo[buf_number].filetype ~= "NvimTree" then
            return true
          end
        end,
      }
    })
  end,
  },
})

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
vim.api.nvim_set_keymap('n', '’', ':OverseerRun<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '›', ':OverseerToggle!<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'ﬁ',  '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'ä', '<C-w>l', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'π',    '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'ö',  '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '≈', ':tabclose<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '∂', ':lua DeleteNode()<CR>', { noremap = true, silent = true })
-- Move lines up/down (Option+Up / Option+Down on macOS)
vim.api.nvim_set_keymap('n', '<M-Up>', ':m .-2<CR>==', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<M-Down>', ':m .+1<CR>==', { noremap = true, silent = true })

-- Move word left/right (Option+Left / Option+Right on macOS)
vim.api.nvim_set_keymap('n', '<M-Left>', 'b', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<M-Right>', 'w', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<M-b>', 'b', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<M-f>', 'w', { noremap = true, silent = true })

vim.api.nvim_set_keymap('i', '<M-Left>', '<C-o>b', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<M-Right>', '<C-o>w', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<M-b>', '<C-o>b', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<M-f>', '<C-o>w', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '˚', ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '∆', ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Esc>', ':noh<CR>', { noremap = true, silent = true })

-- Toggle text wrapping (Option+Z / alt-z)
vim.api.nvim_set_keymap('n', '÷', ':set wrap!<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'Ω', ':set wrap!<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<M-z>', ':set wrap!<CR>', { noremap = true, silent = true })

-- Tab navigation
vim.api.nvim_set_keymap('n', '†', ':tabnew<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '1', '1gt', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '2', '2gt', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '3', '3gt', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '4', '4gt', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '5', '5gt', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '6', '6gt', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '7', '7gt', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '8', '8gt', { noremap = true, silent = true })

-- Toggle bufferline
local bufferline_visible = true
function ToggleBufferline()
  if bufferline_visible then
    vim.opt.showtabline = 0
    bufferline_visible = false
  else
    vim.opt.showtabline = 2
    bufferline_visible = true
  end
end

vim.api.nvim_set_keymap('n', 'ç', ':lua ToggleBufferline()<CR>', { noremap = true, silent = true })

-- Mapping for opening terminal with 't!'
vim.api.nvim_set_keymap('n', 't!', ':lua OpenStyledTerminal()<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>o', function()
  local file = vim.fn.expand('<cfile>')
  if file:match('%.(png|jpg|jpeg|gif|webp|svg)$') then
    vim.fn.jobstart({ 'open', file })
  else
    print("Not an image file")
  end
end, { noremap = true, silent = true })

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
-- Fixed: separators now use {left, right} table format instead of plain list
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '|', right = '|' },
    section_separators = { left = '', right = '' },
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

vim.cmd [[highlight AlphaHeader guifg=#8B0000]]
local alpha = require'alpha'
local startify = require'alpha.themes.startify'

local header_art = {
    "           ██████           ",
    "         █████████          ",
    "     █████████████          ",
    "      ██   █████            ",
    "          ██████            ",
    "        █████████           ",
    "       ██████████           ",
    "       ███████████          ",
    "       ███████ ████         ",
    "       ████████ ████        ",
    "       █████████  ████      ",
    "        ████████    █       ",
    "         ███████████        ",
    "              ██  ",
    "",
    "",
    "      What do you see?      "
}

-- Calculate vertical padding to center the dashboard content
local header_lines = #header_art
local content_height = header_lines + 10 -- header + approximate MRU/footer lines
local pad_top = math.max(0, math.floor((vim.fn.winheight(0) - content_height) / 2))

startify.section.header.val = header_art
startify.section.header.opts = { position = "center", hl = "AlphaHeader" }

-- Recursively center all nested elements in a section
local function center_section(section)
    if section.opts then
        section.opts.position = "center"
    else
        section.opts = { position = "center" }
    end
    if section.val then
        if type(section.val) == "table" then
            for _, item in ipairs(section.val) do
                if type(item) == "table" then
                    center_section(item)
                end
            end
        elseif type(section.val) == "function" then
            -- Wrap dynamic val functions so their output gets centered too
            local orig_fn = section.val
            section.val = function()
                local result = orig_fn()
                if type(result) == "table" then
                    for _, item in ipairs(result) do
                        if type(item) == "table" then
                            center_section(item)
                        end
                    end
                end
                return result
            end
        end
    end
end

center_section(startify.section.top_buttons)
center_section(startify.section.mru)
center_section(startify.section.mru_cwd)
center_section(startify.section.bottom_buttons)
center_section(startify.section.footer)

-- Build a custom layout with top padding for vertical centering
startify.config.layout = {
    { type = "padding", val = pad_top },
    startify.section.header,
    { type = "padding", val = 2 },
    startify.section.top_buttons,
    startify.section.mru,
    startify.section.mru_cwd,
    { type = "padding", val = 1 },
    startify.section.bottom_buttons,
    startify.section.footer,
}

alpha.setup(startify.config)


-- nvim-treesitter Configuration
-- The new 'main' branch removed nvim-treesitter.configs entirely.
-- Highlighting is now provided by Neovim's built-in vim.treesitter.start().
-- Parser installation uses require('nvim-treesitter').install().

-- Enable treesitter highlighting for supported filetypes via autocommand
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua', 'python', 'javascript', 'typescript', 'html', 'css', 'json', 'c', 'cpp' },
  callback = function() vim.treesitter.start() end,
})

-- Install desired parsers (no-op if already installed)
require('nvim-treesitter').install { 'lua', 'python', 'javascript', 'c', 'cpp' }

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
  vim.keymap.set('n', '<leader>o', function()
    local node = api.tree.get_node_under_cursor()
    if node and node.absolute_path:match('%.(png|jpg|jpeg|gif|webp|svg)$') then
        vim.fn.jobstart({ 'open', node.absolute_path })
    end
  end, opts('Open image'))
  -- Set custom mapping for toggle action
  vim.keymap.set('n', '<C-t>', api.tree.toggle, opts('Toggle Tree'))
end

require('nvim-tree').setup {
  actions = {
    open_file = {
        quit_on_open = false,
    },
  },
  tab = {
    sync = {
      open = true,   -- auto-open tree in new tabs if it was open
      close = true,  -- auto-close tree in new tabs if it was closed
    },
  },
  view = {
    width = 30,
    side = 'left',
  },
  sync_root_with_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = true,
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
    api.tree.focus()
  else
    api.tree.open()
  end
end

-- Function to Create New File
function CreateNewFile()
  local filename = vim.fn.input("Enter new file name: ")
  if filename and filename ~= '' then
    vim.cmd('edit ' .. filename)
    vim.cmd('w')
    require('nvim-tree.api').tree.reload()
  end
end

function DeleteNode()
  local node = vim.treesitter.get_node()
  if not node then
    print("no node found")
    return
  end

  print("start node type: " .. node:type())
  
  -- Define which node types we consider to be "top level" chunks that we want to delete perfectly
  local target_types = {
    ['type_definition'] = true,      -- typedef struct/enum
    ['function_definition'] = true,  -- functions
    ['declaration'] = true,          -- variables, forward declarations
    ['preproc_def'] = true,          -- #define macros
    ['preproc_function_def'] = true, -- #define MACRO(x)
    ['preproc_include'] = true,      -- #include
  }

  -- Walk up the tree until we hit one of our target types, OR we hit the root/preproc wrappers
  local current = node
  while current:parent() do
    local parent_type = current:parent():type()
    
    -- If the current node is already a target type, and the parent is NOT a target type, we found our chunk
    if target_types[current:type()] then
      break
    end
    
    -- If we are about to hit the top of the file or a wrapping ifdef, stop and use current
    if parent_type == 'translation_unit' or parent_type == 'preproc_ifdef' or parent_type == 'preproc_if' then
      -- If current is literally the first child of the file (and not what we want), we still break
      break
    end

    current = current:parent()
    print("went up to: " .. current:type())
  end

  local start_row, _, end_row, _ = current:range()
  print("deleting node: " .. current:type() .. " (rows " .. start_row .. " to " .. end_row .. ")")
  
  -- Put it in the unnamed register ("") so we can 'p' it
  local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
  vim.fn.setreg('"', lines)
  
  -- Delete the lines
  vim.cmd((start_row + 1) .. ',' .. (end_row + 1) .. 'd')
end

-- Scrollbar and Neoscroll Configuration
require("scrollbar").setup()
require('neoscroll').setup()
