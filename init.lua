local vim = vim
local execute = vim.api.nvim_command
local fn = vim.fn

-- ensure that packer is installed
local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
    execute 'packadd packer.nvim'
end
vim.cmd('packadd packer.nvim')
local packer = require'packer'
local util = require'packer.util'
packer.init({
  package_root = util.join_paths(vim.fn.stdpath('data'), 'site', 'pack')
})

--- startup and add configure plugins
if vim.fn.has('macunix') then require'packer'.init({max_jobs = 4}) end
require('packer').startup(function()
    use 'hrsh7th/cmp-nvim-lsp'
    use 'neovim/nvim-lspconfig'
    use 'williamboman/nvim-lsp-installer'
    use 'onsails/lspkind-nvim'
    use 'quangnguyen30192/cmp-nvim-ultisnips'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/nvim-cmp'
    use 'Olical/conjure'
    use {
        'phaazon/hop.nvim',
        branch = 'v1',
        config = function()
            require'hop'.setup {keys = 'etovxqpdygfblzhckisuran'}
        end
    }
    use {
        'nvim-telescope/telescope.nvim',
        requires = {{'nvim-lua/plenary.nvim'}}
    }
    use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make'}
    use 'tpope/vim-dispatch'
    use 'tpope/vim-repeat'
    use 'tpope/vim-surround'
    use 'tpope/vim-unimpaired'
    use 'tpope/vim-eunuch'
    use {
        'numToStr/Comment.nvim',
        config = function() require('Comment').setup() end
    }
    use "numToStr/FTerm.nvim"
    use 'romainl/vim-cool'
    use 'tpope/vim-rhubarb'
    use 'vim-scripts/BufOnly.vim'
    use 'markonm/traces.vim'
    use 'djoshea/vim-autoread'
    use 'SirVer/ultisnips'
    use 'jtmkrueger/vim-c-cr'
    use 'tpope/vim-fugitive'
    use 'jiangmiao/auto-pairs'
    use {'prettier/vim-prettier', run = 'npm install'}
    use {
        'nvim-lualine/lualine.nvim',
        requires = {'kyazdani42/nvim-web-devicons', opt = true}
    }
    use {
        'lewis6991/gitsigns.nvim',
        requires = {'nvim-lua/plenary.nvim'},
        config = function() require('gitsigns').setup() end
    }
    use 'gelguy/wilder.nvim'
    use 'p00f/nvim-ts-rainbow'
    use 'shinchu/lightline-gruvbox.vim'
    use 'kyazdani42/nvim-web-devicons'
    use 'kyazdani42/nvim-tree.lua'
    use {
        'goolord/alpha-nvim',
        branch = 'main',
        requires = {'kyazdani42/nvim-web-devicons'}
    }
    use 'itchyny/vim-gitbranch'
    use {'harrisoncramer/gruvbox.nvim', requires = {'rktjmp/lush.nvim'}}
    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
    use 'nvim-treesitter/playground'
    use 'lambdalisue/glyph-palette.vim'
    use 'posva/vim-vue'
    use 'adelarsq/vim-matchit'
    use 'mattn/emmet-vim'
    use 'AndrewRadev/tagalong.vim'
    use 'alvan/vim-closetag'
    use 'hashivim/vim-terraform'
    use 'ap/vim-css-color'
    use 'jparise/vim-graphql'
    use 'vimwiki/vimwiki'
    use {
        "mhartington/formatter.nvim",
        config = function()
            require("formatter").setup({
                filetype = {

                    lua = {
                        function()
                            return {exe = "lua-format", stdin = true}
                        end
                    }
                }
            })
        end
    }
    use {'b0o/mapx.nvim', branch = 'main'}
    -- Lua
    use {
      'abecodes/tabout.nvim',
      config = function()
        require('tabout').setup {
        tabkey = '<Tab>', -- key to trigger tabout, set to an empty string to disable
        backwards_tabkey = '<S-Tab>', -- key to trigger backwards tabout, set to an empty string to disable
        act_as_tab = true, -- shift content if tab out is not possible
        act_as_shift_tab = false, -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
        enable_backwards = true, -- well ...
        completion = true, -- if the tabkey is used in a completion pum
        tabouts = {
          {open = "'", close = "'"},
          {open = '"', close = '"'},
          {open = '`', close = '`'},
          {open = '(', close = ')'},
          {open = '[', close = ']'},
          {open = '{', close = '}'}
        },
        ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
        exclude = {} -- tabout will ignore these filetypes
    }
      end,
      wants = {'nvim-treesitter'}, -- or require if not used so far
      after = {'nvim-cmp'} -- if a completion plugin is using tabs load it before
    }
end)

require("settings")
require("colors")
require("mappings")
require("functions")
require("autocommands")
