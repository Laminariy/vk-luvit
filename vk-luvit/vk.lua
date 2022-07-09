local TokenGenerator = require('./utils/token_generator')
local logger = require('./utils/logger')
local safe_resume = require('./utils/safe_resume')
local stringify_query = require('querystring').stringify
local http = require('simple-http')


local BASE_VK_URL = 'https://api.vk.com/method/'
--- Make vk request
-- @param vk (table) vk object
-- @param method (string) vk method to execute
-- @param params (table|nil) table of method args
-- @return data (table|nil) result or nil if error
-- @return error(nil|table) nil or error
local function request(vk, method, params)
  assert(type(method) == 'string', 'You must provide method name (string)')

  params = params or {}
  local query = {
    v = vk.version,
    access_token = vk.token:get()
  }
  for key, val in pairs(params) do
    query[key] = val
  end
  query = stringify_query(query)
  local url = ('%s%s?%s'):format(BASE_VK_URL, method, query)

  local data, err = http.request('GET', url)
  if not data then
    logger:error(err)
    coroutine.yield()
  end
  safe_resume() -- hack to safe resume coroutine
  if data.error then
    return nil, data.error
  end
  return data.response
end


local vk_mt = {
  __call = request,
  __index = {request = request}
}

--- Create VK object
-- @param token (string|table) token or list of tokens
-- @param version (string|nil) api version
-- @return VK object
return function(token, version)
  local vk = {
    token = TokenGenerator(token),
    version = version or '5.131'
  }
  return setmetatable(vk, vk_mt)
end
