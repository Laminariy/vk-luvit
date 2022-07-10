local stringify = require('json').stringify

--- Parse queue table to VKScript
-- @param queue (table) - queue table (25 or less elements)
-- @return vkscript (string) - correct VKScript
return function(queue)
  assert(#queue<=25, 'Queue must be 25 or less elements!')

  local vk_script_str = "var res=[];%sreturn res;"
  local method_str = "res.push(API.%s(%s));"
  local body_tbl = {}
  local method, params
  for _, req in ipairs(queue) do
    method, params = unpack(req)
    table.insert(body_tbl, method_str:format(method, params and stringify(params) or ''))
  end
  return vk_script_str:format(table.concat(body_tbl))
end
