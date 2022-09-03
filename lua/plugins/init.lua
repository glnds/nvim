-- Utility function for plugin settings
local u = require("functions.utils")

-- Utility settings loader
local setup = function(mod, remote)
	if remote == nil then
		-- If plugin does not need "require" setup, then just set it up.
		require(mod)
	else
		local status = pcall(require, remote)
		if not status then
			print(remote .. " is not downloaded.")
			return
		else
			local local_config = require(mod)
			if type(local_config) == "table" then
				local_config.setup()
			end
		end
	end
end

local no_setup = function(mod)
	local status = pcall(require, mod)
	if not status then
		print(mod .. " is not downloaded.")
		return
	else
		require(mod).setup({})
	end
end

local ft_setup = function(mod, remote, ft)
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = "*." .. ft,
		callback = function()
			setup(mod, remote)
		end,
		desc = "Loads the configuration only after opening the given filetype",
	})
end

local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
	print("Packer installed, please exit NVIM and re-open, then run :PackerInstall")
	return
end

local packer = require("packer")
if u.get_os() == "Darwin" then
	packer.init({ max_jobs = 4 })
end

packer.startup(function(use)
	use("wbthomason/packer.nvim")
	use("neovim/nvim-lspconfig")
	use({ "williamboman/mason.nvim" })
	use({ "williamboman/mason-lspconfig.nvim" })
	use("onsails/lspkind-nvim")
	use("hrsh7th/nvim-cmp")
	use({ "hrsh7th/cmp-nvim-lua", ft = { "lua" } })
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("nvim-lua/plenary.nvim")
	use("rebelot/kanagawa.nvim") -- In colors.lua file
	use({
		"quangnguyen30192/cmp-nvim-ultisnips",
		config = setup("plugins.ultisnips"),
	})
	use({ "Olical/conjure", config = setup("plugins.conjure") })
	use({ "jose-elias-alvarez/null-ls.nvim", config = setup("plugins.null", "null-ls") })
	use({
		"nvim-telescope/telescope.nvim",
		requires = { { "nvim-lua/plenary.nvim" } },
		config = setup("plugins.telescope", "telescope"),
	})
	use({
		"nvim-telescope/telescope-file-browser.nvim",
		requires = "nvim-telescope/telescope.nvim",
	})
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make", requires = "nvim-telescope/telescope.nvim" })
	use("tpope/vim-dispatch")
	use("tpope/vim-repeat")
	use("tpope/vim-surround")
	use("tpope/vim-unimpaired")
	use("tpope/vim-rhubarb")
	use({ "kevinhwang91/nvim-bqf", requires = "junegunn/fzf.vim", config = setup("plugins.bqf", "bqf") })
	use({
		"junegunn/fzf",
		run = function()
			vim.fn["fzf#install"]()
		end,
	})
	use("tpope/vim-eunuch")
	use("tpope/vim-obsession")
	use({ "tpope/vim-sexp-mappings-for-regular-people", ft = { "clojure" } })
	use({ "guns/vim-sexp", ft = { "clojure" } })
	use({ "numToStr/Comment.nvim", config = no_setup("Comment") })
	use({ "samoshkin/vim-mergetool", before = require("plugins.mergetool") })
	use({ "numToStr/FTerm.nvim", config = setup("plugins.fterm", "FTerm") })
	use("romainl/vim-cool")
	use("SirVer/ultisnips")
	use({ "tpope/vim-fugitive", config = setup("plugins.fugitive") })
	use({ "windwp/nvim-autopairs", config = setup("plugins.autopairs", "nvim-autopairs") })
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
		config = setup("plugins.lualine", "lualine"),
	})
	use({
		"alvarosevilla95/luatab.nvim",
		config = setup("plugins/luatab", "luatab"),
		requires = "kyazdani42/nvim-web-devicons",
	})
	use({
		"lewis6991/gitsigns.nvim",
		requires = { "nvim-lua/plenary.nvim" },
		config = setup("plugins.gitsigns", "gitsigns"),
	})
	use({ "gelguy/wilder.nvim", config = setup("plugins.wilder", "wilder") })
	use({ "p00f/nvim-ts-rainbow", requires = "nvim-treesitter/nvim-treesitter" })
	use({
		"nvim-treesitter/nvim-treesitter-context",
		requires = "nvim-treesitter/nvim-treesitter",
		confg = setup("plugins.treesitter-context", "treesitter-context"),
	})
	use({ "kyazdani42/nvim-web-devicons", no_setup("nvim-web-devicons") })
	use({
		"sindrets/diffview.nvim",
		requires = "nvim-lua/plenary.nvim",
		config = setup("plugins.diffview", "diffview"),
		commit = "a45163cb9ee65742cf26b940c2b24cc652f295c9",
	})
	use({ "petertriho/nvim-scrollbar", config = setup("plugins.scrollbar", "scrollbar") })
	use({ "karb94/neoscroll.nvim", config = setup("plugins.neoscroll", "neoscroll") })
	use("itchyny/vim-gitbranch")
	use({ "harrisoncramer/jump-tag", config = setup("plugins.jump-tag", "jump-tag") })
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		config = setup("plugins.treesitter", "nvim-treesitter"),
	})
	use({ "nvim-treesitter/playground", requires = "nvim-treesitter/nvim-treesitter" })
	use("lambdalisue/glyph-palette.vim")
	use({ "posva/vim-vue", ft = { "vue" } })
	use("andymass/vim-matchup")
	use({ "mattn/emmet-vim", ft = { "html", "vue", "javascript", "javascriptreact", "typescriptreact" } })
	use("AndrewRadev/tagalong.vim")
	use("alvan/vim-closetag")
	use("tomasiser/vim-code-dark")
	use({ "harrisoncramer/psql", config = no_setup("psql") })
	use({ "vim-test/vim-test", config = setup("plugins.vim-test") })
	use({ "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" }, config = setup("plugins.dap", "dap") })
	use({ "kazhala/close-buffers.nvim", config = no_setup("close_buffers") })
	use({ "rcarriga/nvim-notify", config = no_setup("notify") })
end)
