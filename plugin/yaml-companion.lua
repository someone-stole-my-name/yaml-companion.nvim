if vim.g.yaml_companion == 1 then
  return
end
vim.g.yaml_companion = 1

vim.api.nvim_create_user_command("YAMLCompanion", function(opts)
  if opts.args == "GetSchema" then
    local schema = require("yaml-companion").get_buf_schema(0)
    print(schema.result[1].name)
  elseif opts.fargs[1] == "SetSchema" then
    print(vim.inspect(opts))
  else
    error("unknown command")
  end
end, {
  nargs = "*",
  complete = function(_, line)
    local l = vim.split(line, "%s+")
    local n = #l - 2

    if n == 0 then
      return vim.tbl_filter(function(val)
        return vim.startswith(val, l[2])
      end, { "GetSchema", "SetSchema" })
    end

    if n == 1 then
      if l[2] ~= "SetSchema" then
        return
      end

      local schemas = {}

      -- add schemas from the language server
      local lsp_schemas = require("yaml-companion.lsp.requests").get_all_jsonschemas(0)
      if lsp_schemas == nil then
        lsp_schemas = {}
      end
      for _, schema in ipairs(lsp_schemas.result or {}) do
        table.insert(schemas, schema.name)
      end

      -- add user defined schemas
      for _, schema in ipairs(require("yaml-companion.config").options.schemas.result or {}) do
        table.insert(schemas, schema.name)
      end

      -- add matchers exposed schemas
      local matchers = require("yaml-companion._matchers")._loaded
      for _, matcher in pairs(matchers) do
        local handles = matcher.handles()
        for _, schema in ipairs(handles) do
          table.insert(schemas, schema.name)
        end
      end

      return vim.tbl_filter(function(val)
        return vim.startswith(val, l[3])
      end, schemas)
    end
  end,
})
