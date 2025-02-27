require("sandu.core.options")
require("sandu.core.keymaps")
require("sandu.core.groups")

-- Dependencies required for this configuration:
-- 1. Neovim 0.9.0 or higher
-- 2. Git (for plugin management)
-- 3. A Nerd Font for icons (https://www.nerdfonts.com)
-- 4. ripgrep (https://github.com/BurntSushi/ripgrep) for Telescope file search
-- 5. fd (https://github.com/sharkdp/fd) for faster file finding
-- 6. Node.js (for LSP servers, formatters and Copilot)
-- 7. npm/yarn (for installing LSP servers)
-- 8. Python 3 and pip (for some plugins and LSP servers)
-- 9. A C compiler (gcc/clang) for Treesitter compilation
--
-- Installation commands for macOS:
-- brew install neovim git ripgrep fd node python
-- npm install -g yarn
--
-- For Linux (Ubuntu/Debian):
-- sudo apt install neovim git ripgrep fd-find nodejs npm python3 python3-pip gcc
-- sudo npm install -g yarn
--
-- After installation, run :checkhealth to verify all dependencies are correctly installed
