local function has_tmux_passthrough()
  if not vim.env.TMUX then
    return true
  end

  local ok, result = pcall(vim.fn.system, { "tmux", "show", "-Apv", "allow-passthrough" })
  if not ok or vim.v.shell_error ~= 0 then
    return false
  end

  return result:gsub("%s+", "") == "on"
end

local function can_render_images()
  if #vim.api.nvim_list_uis() == 0 then
    return false
  end

  return has_tmux_passthrough()
end

return {
  {
    "3rd/image.nvim",
    cond = can_render_images,
    build = false,
    opts = {
      processor = "magick_cli",
      max_height_window_percentage = 80,
      tmux_show_only_in_active_window = true,
    },
  },
  {
    "3rd/diagram.nvim",
    cond = can_render_images,
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
