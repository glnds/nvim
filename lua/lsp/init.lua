local cmp_nvim_lsp_status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local lsp_installer_status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")

if not (cmp_nvim_lsp_status_ok and lsp_installer_status_ok) then
	print("LSPConfig, CMP_LSP, and/or LSPInstaller not installed!")
	return
end

-- Configure CMP
require("lsp.cmp")

-- Map keys after LSP attaches (utility function)
local on_attach = function(client, bufnr)
	local function buf_set_option(...)
		vim.api.nvim_buf_set_option(bufnr, ...)
	end

	buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

	-- Turn off formatting by default, but call it for whichever
	-- language servers override this setting in their on_attach functions.
	client.resolved_capabilities.document_formatting = false

	-- Debounce by 300ms by default
	client.config.flags.debounce_text_changes = 300

	-- We could put the formatters in a specific order via arguments to seq_sync, see :h
	vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()")

	require("compat").remap("n", "gd", vim.lsp.buf.definition, {}, ":lua vim.lsp.buf.definition()<CR>")
	require("compat").remap("n", "K", vim.lsp.buf.hover, {}, ":lua vim.lsp.buf.hover()<CR>")
	require("compat").remap("n", "gi", vim.lsp.buf.implementation, {}, ":lua vim.lsp.buf.implementation()<CR>")
	require("compat").remap("n", "<C-k>", vim.lsp.buf.signature_help, {}, ":lua vim.lsp.buf.signature_help()<CR>")
	require("compat").remap("n", "<leader>[", vim.diagnostic.goto_prev, {}, ":lua vim.diagnostic.goto_prev()<CR>")
	require("compat").remap("n", "<leader>]", vim.diagnostic.goto_next, {}, ":lua vim.diagnostic.goto_next()<CR>")
end

local capabilities = cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())

lsp_installer.on_server_ready(function(server)
	local server_status_ok, server_config = pcall(require, "lsp.servers." .. server.name)
	if not server_status_ok then
		print("The LSP '" .. server.name .. "' does not have a config.")
		server:setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})
	else
		server_config.setup(on_attach, capabilities, server)
	end
end)

-- Global diagnostic settings
vim.diagnostic.config({
	virtual_text = false,
	severity_sort = true,
	update_in_insert = false,
	float = {
		header = "",
		source = "always",
		border = "rounded",
		focusable = true,
	},
})

-- Change Error Signs in Gutter
local signs = { Error = "✘", Warn = " ", Hint = "", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end