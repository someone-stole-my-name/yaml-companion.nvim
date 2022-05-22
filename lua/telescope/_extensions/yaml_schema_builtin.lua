local M = {}

local lsp = require("yaml-companion.lsp.util")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local yaml_schema = function(opts)
  local results = lsp.get_all_yaml_schemas()

  if results == nil then
    return
  end

  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Schema",
    finder = finders.new_table({
      results = results,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.name,
          ordinal = entry.name,
        }
      end,
    }),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        local schema = { result = { { name = selection.value.name, uri = selection.value.uri } } }
        require("yaml-companion.context").schema(0, schema)
      end)
      return true
    end,
  }):find()
end

M.yaml_schema = function(opts)
  yaml_schema(require("telescope.themes").get_dropdown({}))
end

return M
