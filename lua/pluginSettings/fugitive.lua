nnoremap('<leader>gs', ':ToggleGStatus<CR>', 'silent')
nnoremap('<leader>gl', ':ToggleGLog<CR>', 'silent')
nnoremap('<leader>gd', ':ToggleGDiff<CR>', 'silent')
nnoremap('<leader>gp', ':Git push<cr>', 'silent')
nnoremap('<leader>gb', ':Gbrowse<cr>')
nnoremap('<leader>go', ':G open<cr>')
nnoremap('<leader>gm', ':Gvdiffsplit!<cr>', 'silent')
nnoremap('<leader>gf', ':diffget //2<cr>', 'silent')
nnoremap('<leader>gh', ':diffget //3<cr>', 'silent')
nnoremap('<leader>gc', ':Commit<cr>', 'silent')

function _G.ToggleGStatus()
  vim.cmd[[
    if buflisted(bufname('.git/index'))
        bd .git/index
    else
        Git
    endif
  ]]
end

vim.cmd[[ command! ToggleGStatus lua ToggleGStatus() ]]


function _G.ToggleGLog()
  vim.cmd[[
    if buflisted(bufname('fugitive'))
      :cclose
      :execute "normal! :bdelete fugitive*\<C-a>\<CR>"
    else
      Gclog
    endif
  ]]
end

vim.cmd[[ command! ToggleGLog lua ToggleGLog() ]]

function _G.ToggleGDiff()
  vim.cmd[[
    if buflisted(bufname('fugitive'))
      :execute "normal! :bdelete fugitive*\<C-a>\<CR>"
    else
        Gdiff
    endif
  ]]
end

vim.cmd[[ command! ToggleGDiff lua ToggleGDiff() ]]
