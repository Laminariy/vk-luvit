local Class = require("utils.class")
local set_interval = require("timer").setInterval


local function parse_requests(queue)
  -- queue[25]!!!
  local vk_script_str = "var res=[];{BODY}return res;"
  local method_str = "res.push(API.{METHOD}({{PARAMS}}));"
  local param_str = "{PARAM_NAME}:{PARAM_VAL}"
  local body_tbl, params_tbl = {}, {}
  local tmp_param_str, tmp_method_str
  local method, params
  for i, req in ipairs(queue) do
    method, params = unpack(req)
    -- params
    for param_name, param_val in pairs(params or {}) do
      tmp_param_str = string.gsub(param_str, "{PARAM_NAME}", string.format("%q", param_name))
      if type(param_val) == "string" then
        tmp_param_str = string.gsub(tmp_param_str, "{PARAM_VAL}", string.format("%q", param_val))
      else
        tmp_param_str = string.gsub(tmp_param_str, "{PARAM_VAL}", param_val)
      end
      table.insert(params_tbl, tmp_param_str)
    end

    -- method
    tmp_method_str = string.gsub(method_str, "{METHOD}", method)
    if next(params_tbl) then
      tmp_method_str = string.gsub(tmp_method_str, "{PARAMS}", table.concat(params_tbl, ","))
    else
      tmp_method_str = string.gsub(tmp_method_str, "{{PARAMS}}", '')
    end
    table.insert(body_tbl, tmp_method_str)

    params_tbl = {}

    if i == 25 then break end
  end

  return string.gsub(vk_script_str, "{BODY}", table.concat(body_tbl))
end


local VKQueue = Class()

  function VKQueue:init(vk)
    self.vk = vk
    self.queue = {} -- {{method, params}, {method, params}}
    local interval = type(vk.token)=="table" and 1/(20*#vk.token) or 1/20
    local function sender()
      coroutine.wrap(self.send_queue)(self)
    end
    set_interval(interval*1000, sender)
  end

  function VKQueue:send_queue()
    if #self.queue == 0 then return end
    local queue = {}
    local waiters = {}
    local count = math.min(25, #self.queue)
    for i=1, count do
      queue[i], waiters[i] = unpack(self.queue[1])
      table.remove(self.queue, 1)
    end
    local exec_req = parse_requests(queue)
    local res = self.vk:request('execute', {code=exec_req})
    local co_suc, co_err
    if res then
      for i, val in ipairs(res) do
        co_suc, co_err = coroutine.resume(waiters[i], val)
        if not co_suc then
          print(debug.traceback(waiters[i], co_err))
        end
      end
    end
  end

  function VKQueue:request(method, params)
    local thread = coroutine.running()
    assert(thread, "You must invoke this method inside coroutine!")
    table.insert(self.queue, {{method, params}, thread})
    return coroutine.yield()
  end

return VKQueue
