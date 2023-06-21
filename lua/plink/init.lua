local async = require('plenary.async')
local debounce = require('telescope.debounce').debounce_leading
local api = require('plink.api')
-- local u = require('plink.util')
local plugin_finder = require('plink.telescope')
local log = require 'plink.log'

vim.cmd([[sign define plink-search text= texthl=Pmenu]])

local M = {}

local delay = 500

local search_async = async.wrap(function(query, callback)
  callback(api.search(query))
end, 2)

---@param query string
---@return nil
local function search(query)
  log('search = ' .. query)
  if type(query) ~= 'string' then
    return nil
  end

  local run_async, timer = debounce(async.run, delay)

  run_async(function()
    search_async(query, function(plugins)
      return plugins
    end)
  end, function()
    log('successfully fetched query "' .. query .. '"')
    if timer then
      timer:stop()
    end
  end)
end

---@param opts { delay: number } | nil
M.setup = function(opts)
  opts = opts or {}
  if opts.delay then
    delay = opts.delay
  end

  vim.api.nvim_create_user_command('PlinkSearch', plugin_finder, { nargs = 0 })
end

M.search = search

return M
