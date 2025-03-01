# ✨ Sandu's Neovim Setup ✨

Hey there! Welcome to my personalized Neovim configuration. I've crafted this setup to make coding feel like magic - blending speed, functionality, and a touch of elegance. If you enjoy a productive environment that stays out of your way while providing powerful tools at your fingertips, you might love this!

## 🚀 What's Inside?

- 🧩 **Smart Organization** - Everything neatly arranged in modules you can easily tweak
- ⚡ **Lightning Fast** - Lazy-loaded plugins mean you'll never wait for your editor
- 🔍 **LSP Superpowers** - Code intelligence that actually understands your projects
- 🌲 **Treesitter Magic** - Syntax highlighting that actually works, even in complex files
- 🐙 **Git at Your Fingertips** - Seamless version control without leaving the editor
- ✨ **Auto-formatting** - Code stays pretty without you having to think about it
- 🛠️ **Text Wizardry** - Clever mini plugins that make editing text a joy
- 🎨 **Eye Candy** - A beautiful, distraction-free UI that's easy on the eyes

## 📸 See It In Action

<div align="center">
  <div style="display: flex; flex-wrap: wrap; gap: 10px; justify-content: center">
    <img src="./images/SCR-20250228-cbxt.png" width="49%" alt="Editor in action" />
    <img src="./images/SCR-20250228-cdey.png" width="49%" alt="LSP features" />
    <img src="./images/SCR-20250228-caxp.png" width="49%" alt="File navigation" />
    <img src="./images/SCR-20250228-cbkf.png" width="49%" alt="Terminal integration" />
  </div>
</div>

> _Beautiful, isn't it? Function and aesthetics working together!_

## Installation

1. Clone this repository to your Neovim configuration directory:

```bash
git clone git@github.com:sandudorogan/nvim-config.git ~/.config/nvim
```

2. Install dependencies as instructed in the [init.lua](./lua/sandu/core/init.lua) file.

3. Start Neovim. Plugins will be automatically installed on first launch.

## Structure

- `init.lua`: Main entry point for Neovim
- `lua/sandu/core/`: Core Neovim settings
  - `options.lua`: Neovim options
  - `keymaps.lua`: Key mappings
  - `groups.lua`: Autocommand groups
- `lua/sandu/plugins/`: Plugin configurations
- `after/queries/`: Custom treesitter queries

## 💎 Superpowers Included

My favorite plugins that make this config special:

- 🧠 **LSP** - Your code understood, not just highlighted
- 🌳 **Treesitter** - Syntax highlighting that actually works
- 🔭 **Telescope** - Find anything in milliseconds
- 🤖 **Copilot & CodeCompanion** - AI pair programming that feels like magic
- ✨ **Conform.nvim** - Auto-formatting for 40+ languages
- 🧰 **Mini.nvim Toolkit**:
  - Text operations that feel like superpowers
  - Intelligent bracket pairing
  - Quick text surrounding (faster than you can say "quotes")
  - AI-powered text objects

## ✏️ Make It Yours

This config is meant to be a starting point, not a finished product! Here's how to personalize it:

- Tweak behavior in `lua/sandu/core/` files
- Add your favorite plugins to `lua/sandu/plugins/`
- Adjust colorscheme and visuals to match your style

Remember, the best editor is the one that feels like an extension of your thoughts. Happy coding! 💻✨
