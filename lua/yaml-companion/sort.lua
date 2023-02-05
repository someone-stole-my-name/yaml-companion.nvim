local M = {}

local has_ts_utils, ts_utils = pcall(require, "nvim-treesitter.ts_utils")

local treesitter_queries = {
  block_sequences = vim.treesitter.parse_query(
    "yaml",
    [[
      (block_node (block_sequence) @sequence)
    ]]
  ),
  -- captures all the sequence item nodes
  sequence_items = vim.treesitter.parse_query(
    "yaml",
    [[
      (block_sequence_item) @item
    ]]
  ),
}

---@param bufnr number|nil the buffer number
---@return number|nil
local check_bufnr = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if vim.bo[bufnr].filetype ~= "yaml" then
    vim.notify("not a yaml file")
    return
  end

  if not has_ts_utils then
    vim.notify("treesitter not installed")
    return
  end
  return bufnr
end

---@param bufnr number|nil the buffer number
---@return any
local get_root = function(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, "yaml")
  return parser:parse()[1]:root()
end

---Sorts zero or a single item inside a block_sequence node.
---Returns true if the buffer was changed.
---@param node any a block_sequence node
---@param bufnr number|nil the buffer number
---@return nil|boolean
local sort_block_sequence = function(node, bufnr)
  if not node then
    return
  end

  if node:type() ~= "block_sequence" then
    return
  end

  local childs = {}
  for _, child in treesitter_queries.sequence_items:iter_captures(node, bufnr, 0, -1) do
    table.insert(childs, child)
  end

  for idx, child in ipairs(childs) do
    local sibling = childs[idx + 1]
    if sibling ~= nil then
      local sibling_text = vim.treesitter.query.get_node_text(childs[idx + 1], 0)
      local child_text = vim.treesitter.query.get_node_text(child, 0)
      if sibling_text < child_text then
        ts_utils.swap_nodes(sibling, child, bufnr, true)
        return true
      end
    end
  end

  return false
end

---Sorts all the block sequences of the given buffer
---@param bufnr number|nil the buffer number
---@return nil
M.sort_block_sequences = function(bufnr)
  bufnr = check_bufnr(bufnr)
  if not bufnr then
    return
  end

  local changed = false
  repeat
    for _, block_sequence in
      treesitter_queries.block_sequences:iter_captures(get_root(bufnr), bufnr, 0, -1)
    do
      local sort_result = sort_block_sequence(block_sequence, bufnr)
      if sort_result == nil then
        return
      end
      changed = sort_result
    end
  until not changed
end

---Sorts the block sequence under cursor.
---@param winnr number|nil the win number
---@return nil
M.sort_block_sequence_under_cursor = function(winnr)
  -- just to validate plugins and whatnot
  if not check_bufnr() then
    return
  end

  local changed = false
  repeat
    -- this also takes care of updating the tree after a change under the hood
    local root = ts_utils.get_node_at_cursor(winnr, true)
    if root:type() ~= "block_sequence" then
      root = root:parent()
      -- refactor this hack to get the 1st block_sequences under root
      repeat
        for _, block_sequence in treesitter_queries.block_sequences:iter_captures(root, 0, 0, -1) do
          root = block_sequence
          break
        end
      until true == true
    end

    local sort_result = sort_block_sequence(root, 0)
    if sort_result == nil then
      return
    end
    changed = sort_result
  until not changed
end

M.sort_document = function(bufnr)
  M.sort_block_sequences(bufnr)
end

return M
