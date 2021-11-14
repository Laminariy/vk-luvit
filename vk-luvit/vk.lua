local Class = require("./utils/class")
local safe_resume = require("./utils/safe_resume")
local http = require("simple-http")
local uri_encode_component = require("./utils/uri").encode_component


local BASE_VK_URL = "https://api.vk.com/method/"


local function gen_query_string(query_params)
  -- query = {name=val, name=val}
  local query_string = ""
  if next(query_params) then
    for query_key,query_value in pairs(query_params) do
      if type(query_value) == "table" then
        for _,v in ipairs(query_value) do
          query_string = ("%s%s%s=%s"):format(query_string, (#query_string == 0 and "?" or "&"), query_key, uri_encode_component(tostring(v)))
        end
      else
        query_string = ("%s%s%s=%s"):format(query_string, (#query_string == 0 and "?" or "&"), query_key, uri_encode_component(tostring(query_value)))
      end
    end
  end
  return query_string
end

local function vk_request(version, access_token, method, params)
  params = params or {}
  local q_params = {
    v = version,
    access_token = access_token
  }
  for k, v in pairs(params) do
    q_params[k] = v
  end
  local query = gen_query_string(q_params)
  local url = ("%s%s%s"):format(BASE_VK_URL, method, query)
  return http.request("GET", url) --, _, _, _, _, 25000)
end


local VK = Class()

  function VK:init(token, version)
    assert(token, 'You must provide token! (string or table of strings)')
    self.version = version or '5.131'
    self.token = token
  end

  function VK:get_token()
    if type(self.token) == 'table' then
      if not self.token_counter then
        self.token_counter = 1
      end
      local token = self.token[self.token_counter]
      self.token_counter = self.token_counter + 1
      if self.token_counter > #self.token then
        self.token_counter = 1
      end
      return token
    else
      return self.token
    end
  end

  function VK:request(method, params)
    local data, err = vk_request(self.version, self:get_token(), method, params)
    if not data then
      -- TO DO: pretty print error
      print("Error: " .. err)
      coroutine.yield()
    end
    safe_resume() -- hack to safe resume coroutine
    if data.error then
      return nil, data.error
    end
    return data.response
  end

return VK
