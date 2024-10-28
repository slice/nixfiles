local allowed_globals = {}
for key, _ in pairs(_G) do
  table.insert(allowed_globals, key)
end

return {
  build = {
    { atomic = true,        verbose = true },
    { "fnl/**/*macro*.fnl", false },
    { "fnl/**/*.fnl", function(path)
      return string.gsub(path, "/fnl/", "/.hotpot/lua/")
    end },
  },
  clean = { { ".hotpot/lua/**/*.lua", true } },
  compiler = {
    modules = { allowedGlobals = allowed_globals },
  },
}
