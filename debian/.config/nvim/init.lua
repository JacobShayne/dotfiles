-- Minimal security research config
-- No bullshit, just what you need

-- Bootstrap lazy.nvim (just the plugin manager)
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

-- Classic vim settings
vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

-- Better search behavior (case-insensitive until you type capitals)
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Better split defaults (new splits go right/below)
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Create undo directory if it doesn't exist
vim.fn.mkdir(vim.fn.expand("~/.vim/undodir"), "p")

-- Leader key
vim.g.mapleader = " "

-- Essential remaps
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Move lines in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor centered
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Greatest remap ever (paste without losing register)
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Copy to system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Delete to void register
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- Never press Q
vim.keymap.set("n", "Q", "<nop>")

-- Quick replace word under cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Minimal plugins for productive coding
require("lazy").setup({
    -- Telescope (the only finder Primeagen uses)
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.5',
        dependencies = { 
            'nvim-lua/plenary.nvim',
            'nvim-tree/nvim-web-devicons'  -- Icons support since you have Nerd Font
        }
    },

    -- Treesitter (syntax highlighting)
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate'
    },

    -- Harpoon (quick file switching)
    {
        'ThePrimeagen/harpoon',
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" }
    },

    -- Undotree (visual undo history)
    {'mbbill/undotree'},

    -- LSP Zero (simple LSP setup)
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        dependencies = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},
            {'williamboman/mason.nvim'},
            -- Remove mason-lspconfig to avoid the error

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'hrsh7th/cmp-buffer'},
            {'hrsh7th/cmp-path'},
            {'L3MON4D3/LuaSnip'},
        }
    },

    -- Fugitive (git)
    {'tpope/vim-fugitive'},

    -- Git signs (see changes in the gutter)
    {'lewis6991/gitsigns.nvim'},

    -- Comment (gcc to comment)
    {'numToStr/Comment.nvim'},

    -- Formatter (auto-format on save)
    {
        'stevearc/conform.nvim',
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    python = { "ruff_format", "black" },  -- ruff_format is the correct name
                    c = { "clang_format" },
                    cpp = { "clang_format" },
                },
                format_on_save = {
                    timeout_ms = 500,
                    lsp_fallback = true,
                },
            })
        end,
    },

    -- Better diagnostics display (optional but nice)
    {
        "folke/trouble.nvim",
        config = function()
            require("trouble").setup({
                icons = false,  -- no icons needed
            })
            vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>")
            vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>")
        end,
    },

    -- Rose Pine (clean colorscheme)
    {
        'rose-pine/neovim',
        name = 'rose-pine'
    },
})

-- Load plugin configs

-- Colorscheme
vim.cmd('colorscheme rose-pine')

-- Telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set('n', '<leader>lg', builtin.live_grep, {})  -- Live grep (real-time search)
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})    -- Search open buffers
vim.keymap.set('n', '<leader>fd', builtin.diagnostics, {}) -- Search diagnostics
vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})

-- Treesitter
require'nvim-treesitter.configs'.setup {
    ensure_installed = { "c", "lua", "python", "cpp", "rust", "bash", "vimdoc", "vim" },
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}

-- Harpoon
local harpoon = require("harpoon")
harpoon:setup()

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)

-- Undotree
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

-- Fugitive
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

-- Gitsigns
require('gitsigns').setup({
    signs = {
        add = { text = '│' },
        change = { text = '│' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
    },
})

-- Comment
require('Comment').setup()

-- LSP Zero configuration
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
    local opts = {buffer = bufnr, remap = false}

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

-- Clean up diagnostics display (less noisy)
vim.diagnostic.config({
    virtual_text = {
        prefix = '●',
        spacing = 4,
    },
    float = {
        border = 'rounded',
        source = 'always',
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

-- Mason setup (just for installing)
require('mason').setup({})

-- Manual LSP setup (no mason-lspconfig)
local lspconfig = require('lspconfig')

-- Setup servers directly
lspconfig.clangd.setup({})
lspconfig.pyright.setup({})

-- CMP (autocompletion)
local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}

cmp.setup({
    sources = {
        {name = 'path'},
        {name = 'nvim_lsp'},
        {name = 'buffer', keyword_length = 3},
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
    }),
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
})
