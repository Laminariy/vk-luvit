local Class = require("utils.class")
local http = require("simple-http")
local uri_encode_component = require("utils.uri").encode_component


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
  local data, res, err_info = http.request("GET", url) --, _, _, _, _, 25000)
  if not data then
    return nil, res
  end
  return data
end


local VK = Class()

  function VK:init(token, version, error_handler)
    assert(token, 'You must provide token! (string or table of strings)')
    self.version = version or '5.131'
    self.token = token
    self.error_handler = error_handler
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
    err = err or data.error
    if err then
      if self.error_handler then
        self.error_handler(err)
        coroutine.yield()
      end
      return nil, err
    end
    if data.response then
      return data.response
    end
  end

return VK
