return {
  {
    "3rd/image.nvim",
    build = false,
    opts = {
      processor = "magick_cli",
      max_height_window_percentage = 80,
      tmux_show_only_in_active_window = true,
    },
  },
  {
    "3rd/diagram.nvim",
    dependencies = { "3rd/image.nvim" },
    ft = { "markdown" },
    opts = {
      renderer_options = {
        mermaid = {
          background = "transparent",
          theme = "dark",
          scale = 3,
        },
      },
    },
  },
}
