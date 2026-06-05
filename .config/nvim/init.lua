vim.opt.number = true
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8

-- Tabs
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Files
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand('~/.cache/nvim-undo')
vim.opt.autoread = true
vim.opt.autowrite = true

-- Clipboard
vim.opt.clipboard = 'unnamedplus'

-- Shortcuts
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set('n', '<leader>bn', ':bnext<CR>')
vim.keymap.set('n', '<leader>bp', ':bprevious<CR>')

vim.keymap.set('n', 'gh', vim.lsp.buf.hover)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration)
vim.keymap.set('n', 'gr', vim.lsp.buf.references)
vim.keymap.set('n', 'gl', vim.diagnostic.open_float)
vim.keymap.set('n', '<F2>', vim.lsp.buf.rename)
vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action)

vim.keymap.set("n", '<F3>',
    function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end
)


-- Autocommands
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
    callback = function()
        vim.lsp.buf.format()
    end,
})

-- Plugins
vim.pack.add({
    -- Theme
    'https://github.com/Shatur/neovim-ayu',
    'https://github.com/folke/tokyonight.nvim',

    -- Mini deps
    'https://github.com/nvim-mini/mini.icons',
    'https://github.com/nvim-mini/mini.snippets',

    -- Mini text editing
    'https://github.com/nvim-mini/mini.comment',
    'https://github.com/nvim-mini/mini.completion',
    'https://github.com/nvim-mini/mini.move',

    -- Mini workflow
    'https://github.com/nvim-mini/mini.files',
    'https://github.com/nvim-mini/mini.pick',

    -- Mini appearance
    'https://github.com/nvim-mini/mini.cursorword',
    'https://github.com/nvim-mini/mini.hipatterns',
    'https://github.com/nvim-mini/mini.indentscope',
    'https://github.com/nvim-mini/mini.statusline',
    'https://github.com/nvim-mini/mini.tabline',

    -- LSP
    'https://github.com/neovim/nvim-lspconfig',
    'https://github.com/mason-org/mason.nvim',
    'https://github.com/mason-org/mason-lspconfig.nvim',
    'https://github.com/folke/lazydev.nvim',

    -- Syntax highlighting
    'https://gitlab.com/HiPhish/rainbow-delimiters.nvim',

    -- Autopairs
    'https://github.com/windwp/nvim-autopairs',

    -- Scrollbar
    'https://github.com/petertriho/nvim-scrollbar',

    -- Git
    'https://github.com/lewis6991/gitsigns.nvim'

    -- {
    --     src = 'https://github.com/nvim-treesitter/nvim-treesitter',
    --     version = 'master',
    -- }
})


-- Mini deps config
local icons = require('mini.icons')
icons.setup()
icons.tweak_lsp_kind()

require('mini.snippets').setup()

-- Mini text editing config
require('mini.comment').setup()
require('mini.completion').setup()
require('mini.move').setup()

-- Mini workflow config
require('mini.pick').setup()
vim.keymap.set('n', '<leader>ff', ':Pick files<CR>')
vim.keymap.set('n', '<leader>fg', ':Pick grep_live<CR>')

-- Mini appearance config
require('mini.cursorword').setup()

local hipatterns = require('mini.hipatterns')
hipatterns.setup({
    highlighters = {
        -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
        fixme     = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
        hack      = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
        todo      = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
        note      = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },

        -- Highlight hex color strings (`#rrggbb`) using that color
        hex_color = hipatterns.gen_highlighter.hex_color(),
    },
})

require('mini.indentscope').setup()
require('mini.statusline').setup()
require('mini.tabline').setup()

-- LSP Config

require('mason').setup()
require('mason-lspconfig').setup()
require('lazydev').setup()

-- Theme config
require('ayu').setup({
    mirage = false,  -- Set to `true` to use `mirage` variant instead of `dark` for dark background.
    terminal = true, -- Set to `false` to let terminal manage its own colors.
})
require('tokyonight').setup()

vim.cmd('colorscheme tokyonight')

vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'none' })
vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'none' })


-- Syntax highlight config
-- require('nvim-treesitter').setup({
--     ensure_installed = 'all'
-- })

-- Auto pairs config
require("nvim-autopairs").setup()

-- Scroll bar config
require("scrollbar").setup()

-- Git config
require('gitsigns').setup({
    current_line_blame = true
})
