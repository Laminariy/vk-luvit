local uri_encode_component = require('./uri').encode_component

--- Stringify query table
-- @param params (table) query table to be stringified
-- @return query_string (string)
return function(params)
  local query_string = ""
  if next(params) then
    for key, val in pairs(params) do
      if type(val) == 'table' then
        for _, v in ipairs(val) do
          query_string = ('%s%s%s=%s'):format(
              query_string,
              (#query_string == 0 and '?' or '&'),
              key,
              uri_encode_component(tostring(v)))
        end
      else
        query_string = ('%s%s%s=%s'):format(
            query_string,
            (#query_string == 0 and '?' or '&'),
            key,
            uri_encode_component(tostring(val)))
      end
    end
  end
  return query_string
end
