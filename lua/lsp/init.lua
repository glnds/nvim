local cmp_nvim_lsp_status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local mason_status_ok, mason = pcall(require, "mason")
local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
local lsp_format_ok, lsp_format = pcall(require, "lsp-format")
local add_bun_prefix = require("lsp.bun").add_bun_prefix
local u = require("functions.utils")

if not (mason_status_ok and mason_lspconfig_ok and cmp_nvim_lsp_status_ok and lsp_format_ok) then
  vim.api.nvim_err_writeln("Mason, Mason LSP Config, Completion, or LSP Format not installed!")
  return
end

mason.setup()

lsp_format.setup({
  order = {
    "tsserver",
    "eslint",
  }
})

-- Map keys after LSP attaches (utility function)
local on_attach = function(client, bufnr)
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  -- Debounce by 300ms by default
  client.config.flags.debounce_text_changes = 300

  -- This will set up formatting for the attached LSPs
  client.server_capabilities.documentFormattingProvider = true

  -- Turn off semantic tokens (too slow)
  -- client.server_capabilities.semanticTokensProvider = nil

  -- Formatting for Vue handled by Eslint
  -- Formatting for Clojure handled by custom ZPrint function, see lua/lsp/servers/clojure-lsp.lua
  if (u.has_value({ "eslint", "gopls", "astro", "terraformls" }, client.name)) then
    lsp_format.on_attach(client)
  end

  -- Keymaps
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
  vim.keymap.set("n", "gs", function()
    vim.cmd.vsplit()
    vim.lsp.buf.definition()
  end, {})
  vim.keymap.set("n", "gv", function()
    vim.cmd.split()
    vim.lsp.buf.definition()
  end, {})
  vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help)
  vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, {})
  vim.keymap.set("n", "<leader>lq", vim.diagnostic.setqflist, {})
  vim.keymap.set("n", "<leader>li", vim.lsp.buf.implementation, {})
  vim.keymap.set("n", "<leader>lt", vim.lsp.buf.type_definition, {})
  vim.keymap.set("n", "<leader>lr", vim.lsp.buf.references, {})
  vim.keymap.set("n", "<leader>lc", vim.lsp.buf.incoming_calls, {})

  vim.keymap.set("n", "]W", function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
  end)

  vim.keymap.set("n", "[W", function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
  end)

  vim.keymap.set("n", "]w", function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARNING })
  end)

  vim.keymap.set("n", "[w", function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARNING })
  end)


  vim.keymap.set("n", "<leader>d", function()
    vim.diagnostic.setqflist({})
  end)

  -- This is ripped off from https://github.com/kabouzeid/dotfiles, it's for tailwind preview support
  if client.name == "tailwindcss" then
    require("lsp/colorizer").buf_attach(bufnr, { single_column = false, debounce = 500 })
  end
end

local normal_capabilities = vim.lsp.protocol.make_client_capabilities()

-- cmp_nvim_lsp.update_capabilities is deprecated, use cmp_nvim_lsp.default_capabilities
local capabilities = cmp_nvim_lsp.default_capabilities(normal_capabilities)

-- These servers are automatically installed by Mason.
-- We then iterate over their names and load their relevant
-- configuration files, which are stored in lua/lsp/servers,
-- passing along the global on_attach and capabilities functions
-- Current: 3.6.11 Updated: 3.6.18
local servers = {
  "lua_ls@3.6.12",
  "clojure_lsp@2023.01.26-11.08.16",
  "eslint@4.6.0",
  "gopls@v0.13.2",
  "astro@0.29.6",
  "marksman@2023-03-04",
  -- Run via bun, see: lua/lsp/bun.lua --
  "tsserver@3.3.1",
  "tailwindcss@0.0.13",
  "volar@1.8.11",
  "terraformls@v0.30.3"
}

local util = require("lspconfig.util")
-- util.on_setup = util.add_hook_before(util.on_setup, add_bun_prefix)

-- Setup Mason + LSPs + CMP
require("lsp.cmp")

mason_lspconfig.setup({ ensure_installed = servers, automatic_installation = true })

-- Setup each server
for _, s in pairs(servers) do
  local server = s:gsub("@.*", "")
  local server_config_ok, mod = pcall(require, "lsp.servers." .. server)
  if not server_config_ok then
    require("notify")("The LSP '" .. server .. "' does not have a config.", "warn")
  else
    mod.setup(on_attach, capabilities)
  end
end

-- Global diagnostic settings
vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  update_in_insert = false,
  float = {
    header = "",
    source = "always",
    border = "solid",
    focusable = true,
  },
})

-- Removing errors from gutter for now, trying inline errors instead

-- Change Error Signs in Gutter
-- local signs = { Error = "✘", Warn = " ", Hint = "", Info = " " }
local signs = { Error = "", Warn = "", Hint = "", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon })
  -- vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Change border of documentation hover window, See https://github.com/neovim/neovim/pull/13998.
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "solid",
})

vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
  vim.lsp.handlers.signature_help, {
    border = "solid",
  })
