--- Create API wrapper object
-- @param vk (VKRequest) - vk request object
-- @return API wrapper object
return function(vk)
  local method_tbl = {}
  local api_mt = {
    __index = function(tbl, key)
      table.insert(method_tbl, key)
      return tbl
    end,

    __call = function(_, params)
      local method = table.concat(method_tbl, '.')
      -- snake_case replacement
      method = method:gsub('_(%l)', string.upper)
      method_tbl = {}
      return vk:request(method, params)
    end
  }
  return setmetatable({}, api_mt)
end
