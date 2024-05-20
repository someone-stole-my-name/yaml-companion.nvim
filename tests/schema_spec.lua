local eq = assert.are.same

local function wait_until(fn)
  for _ = 1, 10 do
    vim.wait(900)
    local r = fn()
    if r then
      return true
    end
  end
  vim.api.nvim_err_writeln("wait_until: timeout exceeded")
  return false
end

local function buf(input, ft, name)
  local b = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(b, name)
  vim.api.nvim_buf_set_option(b, "filetype", ft)
  vim.api.nvim_command("buffer " .. b)
  vim.api.nvim_buf_set_lines(b, 0, -1, true, vim.split(input, "\n"))
  return wait_until(function()
    local clients = vim.lsp.get_clients()
    if #clients > 0 then
      return true
    end
  end)
end

local function wait_for_schemas()
  return wait_until(function()
    local r = require("yaml-companion.schema").all()
    if r and #r > 1 then
      return true
    end
  end)
end

describe("user defined schemas:", function()
  after_each(function()
    vim.api.nvim_buf_delete(0, { force = true })
    vim.fn.delete("foo.yaml", "rf")
    assert(wait_until(function()
      local clients = vim.lsp.get_clients()
      if #clients == 0 then
        return true
      end
      vim.lsp.stop_client(vim.lsp.get_clients(), true)
    end))
  end)

  local custom_schema = {
    name = "Some custom schema",
    uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.22.5-standalone-strict/all.json",
  }

  it("options.schemas.result should add the schema to the list (legacy)", function()
    local expect = custom_schema
    expect.name = expect.name .. " (legacy)"
    local result = {}

    local yamlconfig = require("yaml-companion").setup({ schemas = { result = { custom_schema } } })
    require("lspconfig")["yamlls"].setup(yamlconfig)

    assert(buf("---\nfoo: bar\n", "yaml", "foo.yaml"))
    assert(wait_for_schemas())

    local all_schemas = require("yaml-companion.schema").all()

    for _, schema in ipairs(all_schemas) do
      if schema.name == custom_schema.name then
        result = schema
        break
      end
    end

    eq(expect.uri, result.uri)
  end)

  it("options.schemas should add the schemas to the list (new)", function()
    local expect = custom_schema
    expect.name = expect.name .. " (new)"
    local result = {}

    local yamlconfig = require("yaml-companion").setup({ schemas = { custom_schema } })
    require("lspconfig")["yamlls"].setup(yamlconfig)

    assert(buf("---\nfoo: bar\n", "yaml", "foo.yaml"))
    assert(wait_for_schemas())

    local all_schemas = require("yaml-companion.schema").all()

    for _, schema in ipairs(all_schemas) do
      if schema.name == custom_schema.name then
        result = schema
        break
      end
    end

    eq(expect.uri, result.uri)
  end)
end)
