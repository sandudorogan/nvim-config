return {
  ["git_files"] = {
    description = "List git files",
    ---@param chat CodeCompanion.Chat
    callback = function(chat)
      local handle = io.popen("git ls-files")
      if handle ~= nil then
        local result = handle:read("*a")
        handle:close()
        chat:add_reference({ content = result }, "git_files", "<git_files>")
      else
        return vim.notify("No git files available", vim.log.levels.INFO, { title = "CodeCompanion" })
      end
    end,
    opts = {
      contains_code = false,
    },
  },
  ["git_status"] = {
    description = "See git status",
    ---@param chat CodeCompanion.Chat
    callback = function(chat)
      local handle = io.popen("git status")
      if handle ~= nil then
        local result = handle:read("*a")
        handle:close()

        if result and result ~= "" then
          chat:add_reference({ content = result }, "git_status", "<git_status>")
        else
          return vim.notify("No changes detected in git diff", vim.log.levels.INFO, { title = "CodeCompanion" })
        end
      else
        return vim.notify("No git status available", vim.log.levels.INFO, { title = "CodeCompanion" })
      end
    end,
    opts = {
      contains_code = true,
    },
  },
  ["git_diff"] = {
    description = "Staged changes",
    ---@param chat CodeCompanion.Chat
    callback = function(chat)
      local handle = io.popen("git diff --staged")
      if handle ~= nil then
        local result = handle:read("*a")
        handle:close()

        if result and result ~= "" then
          chat:add_reference({ content = result }, "git_diff", "<git_diff>")
        else
          return vim.notify("No changes detected in git diff", vim.log.levels.INFO, { title = "CodeCompanion" })
        end
      else
        return vim.notify("Failed to run git diff command", vim.log.levels.INFO, { title = "CodeCompanion" })
      end
    end,
  },
}
