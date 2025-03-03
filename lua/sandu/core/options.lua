vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

opt.wrap = false

opt.scrolloff = 8

opt.jumpoptions = "stack"

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

opt.cursorline = true

-- turn on termguicolors for tokyonight colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

if vim.g.vscode then
    -- Disable some Neovim features that are handled by VSCode
    opt.foldcolumn = "0" -- Disable Neovim's fold column (VSCode handles this)
    opt.foldmethod = "manual" -- Disable Neovim's folding (VSCode handles this)
    opt.foldenable = false -- Disable Neovim's folding (VSCode handles this)
    
    -- Disable Neovim's built-in completion (VSCode handles this)
    opt.completeopt = "menu,menuone,noselect"
    
    -- Disable Neovim's built-in statusline (VSCode handles this)
    opt.laststatus = 0
    
    -- Disable Neovim's built-in command line (VSCode handles this)
    opt.cmdheight = 1
    
    -- Disable Neovim's built-in tabline (VSCode handles this)
    opt.showtabline = 0
    
    -- Disable Neovim's built-in line numbers (VSCode handles this)
    opt.number = false
    opt.relativenumber = false
    
    -- Disable Neovim's built-in sign column (VSCode handles this)
    opt.signcolumn = "no"
    
    -- Disable Neovim's built-in cursor line (VSCode handles this)
    opt.cursorline = false
    
    -- Disable Neovim's built-in cursor column (VSCode handles this)
    opt.cursorcolumn = false
    
    -- Disable Neovim's built-in line wrapping (VSCode handles this)
    opt.wrap = false
    
    -- Disable Neovim's built-in line break (VSCode handles this)
    opt.linebreak = false
    
    -- Disable Neovim's built-in break indent (VSCode handles this)
    opt.breakindent = false
    
    -- Disable Neovim's built-in show mode (VSCode handles this)
    opt.showmode = false
    
    -- Disable Neovim's built-in ruler (VSCode handles this)
    opt.ruler = false
    
    -- Disable Neovim's built-in wildmenu (VSCode handles this)
    opt.wildmenu = false
    
    -- Disable Neovim's built-in wildmode (VSCode handles this)
    opt.wildmode = "list:longest,full"
    
    -- Disable Neovim's built-in wildignore (VSCode handles this)
    opt.wildignore = ""
    
    -- Disable Neovim's built-in wildignorecase (VSCode handles this)
    opt.wildignorecase = false
    
    -- Disable Neovim's built-in wildcharm (VSCode handles this)
    opt.wildcharm = 0
    
    -- Disable Neovim's built-in wildoptions (VSCode handles this)
    opt.wildoptions = ""
    -- Disable Neovim's built-in wildmenu (VSCode handles this)
    opt.wildmenu = false
    
    -- Disable Neovim's built-in wildmode (VSCode handles this)
    opt.wildmode = "list:longest,full"
    
    -- Disable Neovim's built-in wildignore (VSCode handles this)
    opt.wildignore = ""
    
    -- Disable Neovim's built-in wildignorecase (VSCode handles this)
    opt.wildignorecase = false
    
    -- Disable Neovim's built-in wildcharm (VSCode handles this)
    opt.wildcharm = 0
    
    -- Disable Neovim's built-in wildoptions (VSCode handles this)
    opt.wildoptions = ""

    -- Disable some plugins that might conflict with VSCode
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    vim.g.loaded_netrwSettings = 1
    vim.g.loaded_netrwFileHandlers = 1
end
