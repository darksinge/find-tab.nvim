local async = require('plenary.async')
local debounce = require('telescope.debounce').debounce_leading
local api = require('find-tab.api')
local u = require('find-tab.utils')

local function p(v)
  print(vim.inspect(v))
end

local M = {}

local delay = 500

---@param opts { delay: number } | nil
M.setup = function(opts)
  opts = opts or {}
  if opts.delay then
    delay = opts.delay
  end
end

local search_async = async.wrap(function(query, callback)
  callback(api.search(query))
end, 2)

---@param query string
---@return nil
M.search = function(query)
  u.assert_type({ query }, 'string')

  local run, timer = debounce(async.run, delay)
  run(function()
    search_async(query, function(plugins)
      if plugins then
        p(plugins[1])
      end
      return plugins
    end)
  end, function()
    vim.notify('done with query = ' .. query, vim.log.levels.DEBUG)
    if timer then
      timer:stop()
    end
  end)
end

return M
