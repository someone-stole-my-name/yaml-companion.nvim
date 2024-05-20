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
    local clients = vim.lsp.get_clients()
    if #clients > 0 then
      return true
    end
  end)
end

describe("schema detection:", function()
  local yamlconfig = require("yaml-companion").setup()
  require("lspconfig")["yamlls"].setup(yamlconfig)

  it("should detect default schema right after start", function()
    assert(buf("", "yaml", ".gitlab-ci.yml"))
    local expect = { result = { require("yaml-companion.schema").default() } }
    local result = require("yaml-companion").get_buf_schema(0)
    assert.are.same(expect, result)
  end)

  it("should detect 'gitlab-ci' schema", function()
    wait_until(function()
      local result = require("yaml-companion").get_buf_schema(0)
      if result.result[1].name ~= require("yaml-companion.schema").default().name then
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
          uri = "https://raw.githubusercontent.com/ansible-community/schemas/main/f/ansible.json#/$defs/playbook",
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
    vim.api.nvim_buf_delete(0, { force = true })
  end)

  it("should not detect Kubernetes", function()
    assert(buf("---\nkind: Deployment\n", "yaml", "playbook.yml"))
    local expect = {
      result = {
        {
          description = "Ansible playbook files",
          name = "Ansible Playbook",
          uri = "https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/schemas/ansible.json#/$defs/playbook",
        },
      },
    }
    wait_until(function()
      local result = require("yaml-companion").get_buf_schema(0)
      if result.name ~= require("yaml-companion.schema").default().name then
        return true
      end
    end)
    local result = require("yaml-companion").get_buf_schema(0)
    assert.are.same(expect, result)
    vim.api.nvim_buf_delete(0, { force = true })
  end)

  it("should detect Kubernetes", function()
    assert(
      buf(
        "apiVersion: apps/v1\nkind: DaemonSet\nspec:\n  template:\n    spec:\n      containers:\n        - name:\n",
        "yaml",
        "foo.yml"
      )
    )
    local expect = { result = { require("yaml-companion.builtin.kubernetes").handles()[1] } }
    wait_until(function()
      local result = require("yaml-companion").get_buf_schema(0)
      if result.name ~= require("yaml-companion.schema").default().name then
        return true
      end
    end)
    local result = require("yaml-companion").get_buf_schema(0)
    assert.are.same(expect, result)
  end)

  it("should match expected Kubernetes diagnostic", function()
    local expect = {
      'Missing property "selector".',
      'Incorrect type. Expected "string".',
    }

    assert.are.same(
      true,
      wait_until(function()
        if #vim.diagnostic.get() == 2 then
          return true
        end
      end)
    )

    for index, value in ipairs(vim.diagnostic.get()) do
      assert.are.same(expect[index], value.message)
    end
    vim.api.nvim_buf_delete(0, { force = true })
  end)

  it("should detect dummy using dummy matcher", function()
    assert(buf("test: true\n", "yaml", "dummy.yml"))
    local expect = { result = require("yaml-companion._matchers.dummy").handles() }
    wait_until(function()
      local result = require("yaml-companion").get_buf_schema(0)
      if result.result[1].name ~= require("yaml-companion.schema").default().name then
        return true
      end
    end)
    local result = require("yaml-companion").get_buf_schema(0)
    assert.are.same(expect, result)
    vim.api.nvim_buf_delete(0, { force = true })
  end)
end)
