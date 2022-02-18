local Class = require('./class')


local TokenGenerator = Class{}

  --- Create VK Token Generator (Iterator)
  -- @param token (string|table) token or list of tokens
  -- @return TokenGenerator object
  function TokenGenerator:init(token)
    assert(type(token) == 'string' or type(token) == 'table' and next(token),
           'You must provide token (string|table)!')

    self.token = type(token) == 'table' and token or {token}
    self.counter = 0
  end

  --- Get VK Token
  function TokenGenerator:get()
    self.counter = self.counter + 1
    if self.counter > #self.token then
      self.counter = 1
    end
    return self.token[self.counter]
  end

  --- Get tokens count
  function TokenGenerator:count()
    return #self.token
  end

return TokenGenerator
