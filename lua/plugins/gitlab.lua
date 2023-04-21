return {
  "harrisoncramer/gitlab.nvim",
  dependencies = {
    "sindrets/diffview.nvim",
    "rcarriga/nvim-notify",
    "MunifTanjim/nui.nvim"
  },
  build = function()
    require("gitlab").build()
  end,
  config = function()
    local gitlab = require("gitlab")
    vim.keymap.set("n", "<leader>gls", gitlab.summary)
    vim.keymap.set("n", "<leader>gla", gitlab.approve)
    vim.keymap.set("n", "<leader>glR", gitlab.revoke)
    vim.keymap.set("n", "<leader>glc", gitlab.create_comment)
    vim.keymap.set("n", "<leader>gld", gitlab.list_discussions)
    gitlab.setup({
      project_id = 7092381,
      base_branch = "main",
      dev = true,
    })
  end,
}
