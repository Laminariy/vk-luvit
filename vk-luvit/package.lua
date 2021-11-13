  return {
    name = "Laminariy/vk-luvit",
    version = "0.0.3",
    description = "VK API wrapper for luvit",
    tags = { "coro", "http", "vk", "api", "wrapper" },
    license = "MIT",
    author = { name = "Laminariy", email = "dovakin121212@gmail.com" },
    homepage = "https://github.com/Laminariy/vk-luvit",
    dependencies = {
      "RiskoZoSlovenska/simple-http",
      "luvit/secure-socket@1.0.0"
    },
    files = {
      "**.lua",
      "!test*"
    }
  }
