local defer = require("defer-resume")
local log = require("./logger")


--- Safe resume coroutine without stopping programm in case of error
return function()
  local co = coroutine.running()
  defer(coroutine.create(function()
    local success, err = coroutine.resume(co)
    if not success then
      -- TO DO: maybe traceback...
      log:error(err)
    end
  end))
  coroutine.yield()
end
