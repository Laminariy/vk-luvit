local defer = require("defer-resume")

return function()
  local co = coroutine.running()
  defer(coroutine.create(function()
    local success, err = coroutine.resume(co)
    if not success then
      -- TO DO: pretty print error
      print(err)
    end
  end))
  coroutine.yield()
end
