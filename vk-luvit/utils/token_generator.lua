local function get_token(generator)
  generator.counter = generator.counter + 1
  if generator.counter > #generator.token then
    generator.counter = 1
  end
  return generator.token[generator.counter]
end

local tk_generator_mt = {
  __len = function(gen)
    return #gen.token
  end,
  __call = get_token,
  __index = {get = get_token}
}


--- Create VK Token Generator (Iterator)
-- @param token (string|table) token or list of tokens
-- @return TokenGenerator object
return function(token)
  assert(type(token) == 'string' or type(token) == 'table' and next(token),
         'You must provide token (string|table)!')

  local tk_generator = {
    token = type(token) == 'table' and token or {token},
    counter = 0
  }
  return setmetatable(tk_generator, tk_generator_mt)
end
