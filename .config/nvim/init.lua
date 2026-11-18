-- Shared $HOME across glibc Linux distros, Alpine (musl) and FreeBSD. Native
-- artifacts (.so files, treesitter parsers, LSP binaries) are not portable, so
-- keep Neovim's data/state/cache dirs per platform. Config stays shared.
do
    -- 'packpath' was initialized before init.lua ran, from the startup XDG vars
    local startup_site = vim.fn.stdpath('data') .. '/site'
    local data_root = vim.fs.dirname(vim.fn.stdpath('data'))
    local state_root = vim.fs.dirname(vim.fn.stdpath('state'))
    local cache_root = vim.fs.dirname(vim.fn.stdpath('cache'))

    --- glibc or musl on Linux, from the ELF interpreter in /proc/self/exe.
    --- The compiler triple is only a fallback for when /proc is unavailable.
    local function detect_libc()
        local fd = vim.uv.fs_open('/proc/self/exe', 'r', 438)
        if fd then
            local head = vim.uv.fs_read(fd, 4096, 0) or ''
            vim.uv.fs_close(fd)
            if head:find('ld-musl', 1, true) then return '-musl' end
            if head:find('ld-linux', 1, true) then return '-gnu' end
        end
        for _, cc in ipairs({ 'cc', 'clang', 'gcc' }) do
            local ok, out = pcall(function()
                return vim.system({ cc, '-dumpmachine' }, { text = true }):wait(1000)
            end)
            if ok and out.code == 0 and out.stdout then
                if out.stdout:find('musl', 1, true) then return '-musl' end
                if out.stdout:find('gnu', 1, true) then return '-gnu' end
            end
        end
        return ''
    end

    --- Distro ID from /etc/os-release (e.g. 'arch', 'nixos', 'alpine') so that
    --- NixOS does not share artifacts with another glibc distribution.
    local function detect_distro()
        local file = io.open('/etc/os-release', 'r')
        if not file then return '' end
        local distro
        for line in file:lines() do
            local value = line:match('^ID="?([%w%._%-]+)"?%s*$')
            if value then
                distro = value:lower()
                break
            end
        end
        file:close()
        return distro and '-' .. distro or ''
    end

    local u = vim.uv.os_uname()
    local sysname = u.sysname:lower()
    local arch = u.machine:lower():gsub('^amd64$', 'x86_64')
    local is_linux = sysname == 'linux'
    local id = ('%s-%s%s%s'):format(
        sysname,
        arch,
        is_linux and detect_libc() or '',
        is_linux and detect_distro() or ''
    )

    vim.env.XDG_DATA_HOME = data_root .. '/' .. id
    vim.env.XDG_STATE_HOME = state_root .. '/' .. id
    vim.env.XDG_CACHE_HOME = cache_root .. '/' .. id

    -- 'packpath' is initialized before init.lua runs, from the XDG vars at
    -- startup: put the per-platform dir first and drop the shared legacy one.
    local packpath = {}
    for _, dir in ipairs(vim.split(vim.o.packpath, ',')) do
        if dir ~= startup_site and dir ~= startup_site .. '/after' then
            packpath[#packpath + 1] = dir
        end
    end
    table.insert(packpath, 1, vim.fn.stdpath('data') .. '/site')
    vim.opt.packpath = table.concat(packpath, ',')
end

vim.opt.number = true
vim.opt.scrolloff = 6
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
vim.keymap.set('n', '<leader>bk', ':bdelete<CR>')

vim.keymap.set('n', 'gh', vim.lsp.buf.hover)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration)
vim.keymap.set('n', 'gr', vim.lsp.buf.references)
vim.keymap.set('n', 'gl', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename)
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action)

vim.keymap.set("n", '<leader>li',
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

vim.api.nvim_create_autocmd("VimResized", {
    pattern = "*",
    command = "wincmd =",
})

-- Plugins
vim.pack.add({
    -- Theme
    'https://github.com/Shatur/neovim-ayu',
    'https://github.com/folke/tokyonight.nvim',
    'https://github.com/ellisonleao/gruvbox.nvim',

    -- Treesitter
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/davidmh/mdx.nvim',

    -- Mini deps
    'https://github.com/nvim-mini/mini.icons',
    'https://github.com/nvim-mini/mini.snippets',

    -- Mini text editing
    'https://github.com/nvim-mini/mini.comment',
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

    -- blink
    'https://github.com/saghen/blink.lib',
    'https://github.com/rafamadriz/friendly-snippets',
    'https://github.com/saghen/blink.cmp',
    'https://github.com/saghen/blink.pairs',

    -- LSP
    'https://github.com/neovim/nvim-lspconfig',
    'https://github.com/mason-org/mason.nvim',
    'https://github.com/mason-org/mason-lspconfig.nvim',
    'https://github.com/folke/lazydev.nvim',
    'https://github.com/j-hui/fidget.nvim',

    -- Scrollbar
    'https://github.com/mihovilrak/scroll.nvim',

    -- Git
    'https://github.com/lewis6991/gitsigns.nvim',

    -- Which key
    'https://github.com/folke/which-key.nvim',

    -- Oil
    'https://github.com/stevearc/oil.nvim',
    'https://github.com/refractalize/oil-git-status.nvim',
    'https://github.com/JezerM/oil-lsp-diagnostics.nvim',

    'https://github.com/obsidian-nvim/obsidian.nvim'

    -- AI
    -- 'https://github.com/github/copilot.vim',
})

-- Mini deps config
local icons = require('mini.icons')
icons.setup()
icons.tweak_lsp_kind()

require('mini.snippets').setup()

-- Mini text editing config
require('mini.comment').setup()
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

-- Blink
local cmp = require('blink.cmp')
cmp.build():pwait()
cmp.setup({
    keymap = { preset = 'default' },
    completion = { documentation = { auto_show = true } },
    sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
    fuzzy = { implementation = "rust" }
})

local pairs = require('blink.pairs')
pairs.build():pwait()
pairs.setup()

-- LSP Config
require('mason').setup()

require('mason-lspconfig').setup({
    automatic_enable = true
})
require('lazydev').setup()
require('fidget').setup({})

-- Theme config
require('ayu').setup({
    mirage = false,  -- Set to `true` to use `mirage` variant instead of `dark` for dark background.
    terminal = true, -- Set to `false` to let terminal manage its own colors.
})
require('tokyonight').setup()
require('gruvbox').setup()

vim.cmd('colorscheme gruvbox')

-- -- Treesitter
-- -- NOTE: 'stable' is a parser *tier* (only ~10 parsers), not "all common
-- -- languages" -- javascript/typescript live in the 'unstable' tier.
-- -- 'all' expands to every parser nvim-treesitter knows about (300+), so the
-- -- first launch spends a while downloading and compiling in the background.
-- require('nvim-treesitter').install({ 'all' })

vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
        if args.match == 'mdx' then -- handled by mdx plugin
            return
        end

        local lang = vim.treesitter.language.get_lang(args.match)
        if not lang then
            return
        end
        pcall(vim.treesitter.start, args.buf, lang)
    end,
})

-- Scroll bar config
require("scroll").setup({
    enabled = true,

    vertical = {
        enabled = true,
        width = 2,
    }
})

-- Git config
require('gitsigns').setup({
    current_line_blame = true
})

-- Which key
require('which-key').setup()

-- Oil
require('oil').setup({
    win_options = {
        signcolumn = "yes:2", -- for oil-git-status
    },
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

require('oil-git-status').setup({})
require('oil-lsp-diagnostics').setup()

-- require('obsidian').setup({
--     legacy_commands = false, -- silcene warning
--     picker = {
--         name = 'mini.pick'
--     },
--     workspaces = {
--         {
--             name = 'vault',
--             path = '/mnt/shared/vault'
--         }
--     }
-- })
