--[[
Platform module

Platform module defines platform specific values.
]]

local platform = {}

-- Extension of dynamic libraries (eg: .dll, .so, .dylib)
local dynlibext = package.cpath:match("%p[\\|/]?%p(%a+)")

--[[
The separator for directories on the platform.
Usually '/' on Linux and '\' on Windows.
]]
platform.dir_separator = _G.package.config:sub(1,1)

-- Whether we are running on Windows
platform.is_windows = platform.dir_separator == '\\'

-- Whether we are running on Unix.
platform.is_unix = not platform.is_windows

-- Whether we are running on Linux.
platform.is_linux = platform.is_unix and dynlibext == 'so'

-- Whether we are running on MacOS.
platform.is_macos = platform.is_unix and dynlibext == 'dylib'

--[[
The separator for the PATH environment variable on the platform.
Usually ':' on Linux and ';' on Windows.
]]
platform.path_separator = platform.is_windows and ';' or ':'

-- Host CPU word size in bits, usually 32 or 64
platform.cpu_bits = string.packsize('T') * 8

-- Separator of LUA_PATH variable.
platform.luapath_separator = package.config:match('.[\r\n]+(.)')

return platform
