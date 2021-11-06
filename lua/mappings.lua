-- Use plugin for easier remapping https://github.com/b0o/mapx.nvim
require'mapx'.setup{ global = true }

-- Creating and moving around splits
nnoremap('ss', ':split<Return><C-w>w')
nnoremap('sv', ':vsplit<Return><C-w>w')
nnoremap('sh', '<C-w>h')
nnoremap('sj', '<C-w>j')
nnoremap('sk', '<C-w>k')
nnoremap('sl', '<C-w>l')
nnoremap('sq', '<C-w>q')
nnoremap('sp', '<C-w><C-p>')

-- Resize splits
nnoremap('<C-w><left>', '<C-w><')
nnoremap('<C-w><right>', '<C-w>>')
nnoremap('<C-w><up>', '<C-w>')
noremap('<C-w><down>', '<C-w>-')


-- Buffer management
nnoremap('<leader>-', ':bd<CR>', "silent")
nnoremap('<C-u>', ':bnext<CR>', "silent")
nnoremap('<C-p>', ':bprev<CR>', "silent")
nnoremap('<C-t>', '<C-^>', "silent")

-- " Allows numbered jumps to be saved to the jumplist, for use w/ C-o and C-i
vim.api.nvim_exec("nnoremap <expr> k (v:count > 1 ? \"m'\" . v:count : '') . 'k'", false)
vim.api.nvim_exec("nnoremap <expr> j (v:count > 1 ? \"m'\" . v:count : '') . 'j'", false)

-- Source/edit .vimrc file
nnoremap('<leader>sv', ':source $MYVIMRC<cr>')
nnoremap('<leader>vv', ':e $MYVIMRC<cr>')

-- Miscellaneous
nnoremap('<C-a>', '<esc>ggVG<CR>') -- Select all
nnoremap('*', ':keepjumps normal! mi*`i<CR>`') -- " Use * to add w/out jumping
nnoremap('<silent> <Leader>y', '"*y') -- Copy to clipboard
nnoremap('H', ':w<CR>') -- Quick save
nnoremap('C-l', 'zL') -- Scroll to right
nnoremap('C-h', 'zH') -- Scroll to left
nnoremap('Y', 'y$') -- Copy until end of line
inoremap('<C-l>', '<Right>') -- Move right in insert
vim.cmd[[ vnoremap <expr>y "my\"" . v:register . "y`y" ]] -- Jump to end of visual copy