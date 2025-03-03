vim.g.mapleader = " "
vim.g.maplocalleader = ","

local keymap = vim.keymap -- for conciseness

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

if vim.g.vscode then
    keymap.set("n", "<leader>ot", "<cmd>vscode-terminal-tabnew<CR>", { desc = "Open terminal" }) -- open terminal

    -- Commentary
    keymap.set("n", "<leader>gc", "<Plug>VSCodeCommentary", { desc = "Commentary" })
    keymap.set("n", "<leader>gcc", "<Plug>VSCodeCommentaryLine", { desc = "Commentary" })

    -- VSCode Jumplist navigation
    keymap.set("n", "<C-o>", "<Cmd>call VSCodeNotify('workbench.action.navigateBack')<CR>", { desc = "Jump back" })
    keymap.set("n", "<C-i>", "<Cmd>call VSCodeNotify('workbench.action.navigateForward')<CR>", { desc = "Jump forward" })

    -- VSCode specific file operations
    keymap.set("n", "<leader>fs", "<Cmd>call VSCodeNotify('workbench.action.files.save')<CR>", { desc = "Save file" })
    keymap.set("n", "<leader>fsa", "<Cmd>call VSCodeNotify('workbench.action.files.saveAll')<CR>", { desc = "Save all files" })
    keymap.set("n", "<leader>fsn", "<Cmd>call VSCodeNotify('workbench.action.files.saveAs')<CR>", { desc = "Save file as" })

    -- VSCode specific window management
    keymap.set("n", "<leader>wv", "<Cmd>call VSCodeNotify('workbench.action.splitEditorRight')<CR>", { desc = "Split right" })
    keymap.set("n", "<leader>wh", "<Cmd>call VSCodeNotify('workbench.action.splitEditorDown')<CR>", { desc = "Split down" })
    keymap.set("n", "<leader>wx", "<Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>", { desc = "Close editor" })
    keymap.set("n", "<leader>wo", "<Cmd>call VSCodeNotify('workbench.action.closeOtherEditors')<CR>", { desc = "Close other editors" })

    -- VSCode specific tab management
    keymap.set("n", "<leader>tn", "<Cmd>call VSCodeNotify('workbench.action.nextEditor')<CR>", { desc = "Next tab" })
    keymap.set("n", "<leader>tp", "<Cmd>call VSCodeNotify('workbench.action.previousEditor')<CR>", { desc = "Previous tab" })
    keymap.set("n", "<leader>tx", "<Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>", { desc = "Close tab" })

    -- VSCode specific search and replace
    keymap.set("n", "<leader>sr", "<Cmd>call VSCodeNotify('workbench.action.replaceInFiles')<CR>", { desc = "Search and replace" })
    keymap.set("n", "<leader>sf", "<Cmd>call VSCodeNotify('workbench.action.quickOpen')<CR>", { desc = "Quick file open" })
    keymap.set("n", "<leader>ss", "<Cmd>call VSCodeNotify('workbench.action.showAllSymbols')<CR>", { desc = "Show all symbols" })

    -- VSCode specific UI
    keymap.set("n", "<leader>ui", "<Cmd>call VSCodeNotify('workbench.action.toggleSidebarVisibility')<CR>", { desc = "Toggle sidebar" })
    keymap.set("n", "<leader>ue", "<Cmd>call VSCodeNotify('workbench.action.togglePanel')<CR>", { desc = "Toggle panel" })
    keymap.set("n", "<leader>uz", "<Cmd>call VSCodeNotify('workbench.action.toggleZenMode')<CR>", { desc = "Toggle zen mode" })
else
    keymap.set("n", "<leader>ot", "<cmd>terminal<CR>", { desc = "Open terminal" }) -- open terminal
end

-- Ensure Ctrl+I works correctly in Clojure files
vim.api.nvim_create_autocmd("FileType", {
    pattern = "clojure",
    callback = function()
        vim.keymap.set("n", "<C-i>", "<C-i>", { noremap = true, buffer = true })
    end,
})
