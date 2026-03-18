-- Keymap to move a line up/down
-- TODO: Move up the first line deletes it
-- TODO: Moving up the last line move it twice
vim.keymap.set('n', '<A-UP>'  , '<S-V>dkP')
vim.keymap.set('n', '<A-DOWN>', '<S-V>dp')

-- Keymap to duplicate down a line up/down
vim.keymap.set('n', '<C-D>', '<S-V>yp')