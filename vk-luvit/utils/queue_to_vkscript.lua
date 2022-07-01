--- Parse queue table to VKScript
-- @param queue (table) - queue table (25 or less elements)
-- @return vkscript (string) - correct VKScript
return function(queue)
  assert(#queue<=25, 'Queue must be 25 or less elements!')

  local vk_script_str = "var res=[];{BODY}return res;"
  local method_str = "res.push(API.{METHOD}({{PARAMS}}));"
  local param_str = "{PARAM_NAME}:{PARAM_VAL}"
  local body_tbl, params_tbl = {}, {}
  local tmp_param_str, tmp_method_str
  local method, params
  for _, req in ipairs(queue) do
    method, params = unpack(req)

    -- params
    for param_name, param_val in pairs(params or {}) do
      tmp_param_str = string.gsub(param_str, "{PARAM_NAME}", string.format('"%s"', param_name))
      if type(param_val) == "string" then
        if param_val:find('\"') == 1 and param_val:find('\"', #param_val) == #param_val then
          tmp_param_str = string.gsub(tmp_param_str, "{PARAM_VAL}", param_val)
        else
          param_val = param_val:gsub('\n', '\\n')
          tmp_param_str = string.gsub(tmp_param_str, "{PARAM_VAL}", string.format('"%s"', param_val))
        end
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
  end

  return string.gsub(vk_script_str, "{BODY}", table.concat(body_tbl))
end
