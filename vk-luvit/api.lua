local vk = require("./vk")
local vk_queue = require("./queue")

local creator_mt = {}

  function creator_mt.__call(_, token, version, queued, error_handler)
    local api_mt = {
      api_tbl = {},
      vk = queued and vk_queue(vk(token, version, error_handler)) or vk(token, version, error_handler)
    }

      function api_mt.__index(tbl, key)
        table.insert(api_mt.api_tbl, key)
        return tbl
      end

      function api_mt.__call(_, params)
        local method = table.concat(api_mt.api_tbl, ".")
        -- snake_case replacement
        method = method:gsub("_(%l)", string.upper)
        api_mt.api_tbl = {}
        return api_mt.vk:request(method, params)
      end

    return setmetatable({}, api_mt)
  end

return setmetatable({}, creator_mt)
