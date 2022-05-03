local function wait_until(fn)
  for _ = 1, 10 do
    vim.wait(400)
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
    local clients = vim.lsp.get_active_clients()
    if #clients > 0 then
      return true
    end
  end)
end

describe("schema detection:", function()
  it("should detect default schema right after start", function()
    assert(buf("", "yaml", ".gitlab-ci.yml"))
    local expect = require("yaml-companion.context").default_schema()
    local result = require("yaml-companion").get_buf_schema(0)
    assert.are.same(expect, result)
  end)

  it("should detect 'gitlab-ci' schema", function()
    wait_until(function()
      local result = require("yaml-companion").get_buf_schema(0)
      if
        result.result[1].name ~= require("yaml-companion.context").default_schema().result[1].name
      then
        return true
      end
    end)

    local expect = {
      result = {
        {
          description = "JSON schema for configuring Gitlab CI",
          name = "gitlab-ci",
          uri = "https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json",
        },
      },
    }
    local result = require("yaml-companion").get_buf_schema(0)
    assert.are.same(expect, result)
  end)

  it("should change 'gitlab-ci' to 'Ansible Playbook' schema", function()
    local schema = {
      result = {
        {
          description = "Ansible playbook files",
          name = "Ansible Playbook",
          uri = "https://raw.githubusercontent.com/ansible-community/schemas/main/f/ansible.json#/definitions/playbook",
        },
      },
    }

    require("yaml-companion").set_buf_schema(0, schema)

    wait_until(function()
      if "gitlab-ci" ~= require("yaml-companion").get_buf_schema(0).result[1].name then
        return true
      end
    end)

    local expect = schema
    local result = require("yaml-companion").get_buf_schema(0)
    assert.are.same(expect, result)
  end)
end)
