-- Keymap to move a line up/down
vim.keymap.set("v", "<A-UP>"  , ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "<A-DOWN>", ":m '>+1<CR>gv=gv")

-- Keymap to duplicate down a line up/down
vim.keymap.set('n', '<C-D>', '<S-V>yp')
