local lusted = require 'nelua.thirdparty.lusted'
local describe, it = lusted.describe, lusted.it

local config = require 'nelua.configer'.get()
local expect = require 'spec.tools.expect'

describe("Lua generator", function()

it("empty file", function()
  expect.generate_lua("", "")
end)
it("return", function()
  expect.generate_lua("return")
  expect.generate_lua("return 1")
  expect.generate_lua("return 1, 2")
end)
it("number", function()
  expect.generate_lua("return 1, 1.2, 1e2, 1.2e3, 0x1f, 0b10",
                      "return 1, 1.2, 1e2, 1.2e3, 0x1f, 0x2")
  expect.generate_lua("return 0x3p5, 0x3.5, 0x3.5p7, 0xfa.d7p-5, 0b11.11p2",
                      "return 0x60, 3.3125, 0x1a8, 7.8387451171875, 0xf")
  expect.generate_lua("return 0x0, 0xffffp4",
                      "return 0x0, 0xffff0")
  expect.generate_lua("return 0xffffffffffffffff.001",
                      "return 1.8446744073709552e+19")
end)
it("string", function()
  expect.generate_lua([[return 'a', "b", [=[c]=] ]], [[return "a", "b", "c"]])
  expect.generate_lua([[return "'", '"']])
  expect.generate_lua([[return "'\001", '"\001']])
end)
it("boolean", function()
  expect.generate_lua("return true, false")
end)
it("nil", function()
  expect.generate_lua("return nil")
end)
it("varargs", function()
  expect.generate_lua("return ...")
end)
it("table", function()
  expect.generate_lua("return {}")
  expect.generate_lua('local a\nreturn {a, "b", 1}')
  expect.generate_lua('return {a = 1, [1] = 2}')
end)
it("function", function()
  expect.generate_lua("return function() end")
  expect.generate_lua("return function()\n  return\nend")
  expect.generate_lua("return function(a, b, c) end")
end)
it("indexing", function()
  expect.generate_lua("local a\nreturn a.b")
  expect.generate_lua("local a, b\nreturn a[b], a[1]")
  expect.generate_lua('return ({})[1]', 'return ({})[1]')
  expect.generate_lua('return ({}).a', 'return ({}).a')
end)
it("call", function()
  expect.generate_lua("local f\nf()")
  expect.generate_lua("local f\nreturn f()")
  expect.generate_lua("local f, g\nf(g())")
  expect.generate_lua("local f, a\nf(a, 1)")
  expect.generate_lua("local f\nf 'a'", 'local f\nf("a")')
  expect.generate_lua("local f\nf {}", 'local f\nf({})')
  expect.generate_lua('local a\na.f()')
  expect.generate_lua('local a\na.f "s"', 'local a\na.f("s")')
  expect.generate_lua("local a\na.f {}", "local a\na.f({})")
  expect.generate_lua("local a\na:f()")
  expect.generate_lua("local a\nreturn a:f()")
  expect.generate_lua("local a\na:f(a, 1)")
  expect.generate_lua('local a\na:f "s"', 'local a\na:f("s")')
  expect.generate_lua("local a\na:f {}", 'local a\na:f({})')
  --expect.generate_lua('("a"):len()', '("a"):len()')
  expect.generate_lua('local g\ng()()', 'local g\ng()()')
  expect.generate_lua('({})()', '({})()')
  --expect.generate_lua('("a"):f()', '("a"):f()')
  expect.generate_lua('local g\ng():f()', 'local g\ng():f()')
  expect.generate_lua('({}):f()', '({}):f()')
end)
it("if", function()
  expect.generate_lua("local a\nif a then\nend")
  expect.generate_lua("local a, b\nif a then\nelseif b then\nend")
  expect.generate_lua("local a, b\nif a then\nelseif b then\nelse\nend")
end)
it("switch", function()
  expect.generate_lua("switch 0 case 1 then else end", [[
local __switchval1 = 0
if __switchval1 == 1 then
else
end]])
  expect.generate_lua("switch 0 case 1 then local f f() case 2 then local g g() else local h h() end",[[
local __switchval1 = 0
if __switchval1 == 1 then
  local f
  f()
elseif __switchval1 == 2 then
  local g
  g()
else
  local h
  h()
end]])
end)
it("do", function()
  expect.generate_lua("do\n  return\nend")
end)
it("while", function()
  expect.generate_lua("local a\nwhile a do\nend")
end)
it("repeat", function()
  expect.generate_lua("local a\nrepeat\nuntil a")
end)
it("for", function()
  expect.generate_lua("for i=1,10 do\nend")
  expect.generate_lua("for i=1,10,2 do\nend")
  expect.generate_lua("local a, f\nfor i in a, f() do\nend")
  expect.generate_lua("local f\nfor i, j, k in f() do\nend")
  expect.generate_lua("local f\nfor _ in f() do\nend", "local f\nfor _ in f() do\nend")
end)
it("break", function()
  expect.generate_lua("while true do\n  break\nend")
end)
it("goto", function()
  expect.generate_lua("::mylabel::\ngoto mylabel")
end)
it("variable declaration", function()
  expect.generate_lua("local a")
  expect.generate_lua("local a = 1")
  expect.generate_lua("local a, b, c = 1, 2, nil")
  expect.generate_lua("local a, b, c = 1, 2, 3")
  expect.generate_lua("local a, b = 1", "local a, b = 1, nil")
  expect.generate_lua("local function f() local a end", "local function f()\n  local a\nend")
end)
it("assignment", function()
  expect.generate_lua("local a: any\na = 1", "local a\na = 1")
  expect.generate_lua("local a: any, b: any\na, b = 1, 2", "local a, b\na, b = 1, 2")
  expect.generate_lua("local a: any, x: any, y: any\na.b, a[1] = x, y", "local a, x, y\na.b, a[1] = x, y")
end)
it("function definition", function()
  expect.generate_lua("local function f()\nend")
  expect.generate_lua("local function f()\nend")
  expect.generate_lua("local function f(a)\nend")
  expect.generate_lua("local function f(a, b, c)\nend")
  expect.generate_lua("local a\nfunction a.f()\nend")
  expect.generate_lua("local a\nfunction a.b.f()\nend")
  expect.generate_lua("local a\nfunction a:f()\nend")
  expect.generate_lua("local a\nfunction a.b:f()\nend")
  expect.generate_lua(
    "local function f(a: integer): integer\nreturn 1\nend",
    "local function f(a)\n  return 1\nend")
end)
it("unary operators", function()
  expect.generate_lua("local a\nreturn not a")
  expect.generate_lua("local a\nreturn -a")
  expect.generate_lua("local a\nreturn ~a")
  expect.generate_lua("local a\nreturn #a")
end)
it("binary operators", function()
  expect.generate_lua("local a, b\nreturn a or b, a and b")
  expect.generate_lua("local a, b\nreturn a ~= b, a == b")
  expect.generate_lua("local a, b\nreturn a <= b, a >= b")
  expect.generate_lua("local a, b\nreturn a < b, a > b")
  expect.generate_lua("local a, b\nreturn a | b, a ~ b, a & b")
  expect.generate_lua("local a, b\nreturn a << b, a >> b")
  expect.generate_lua("local a, b\nreturn a + b, a - b")
  expect.generate_lua("local a, b\nreturn a * b, a / b, a // b")
  expect.generate_lua("local a, b\nreturn a % b")
  expect.generate_lua("local a, b\nreturn a ^ b")
  expect.generate_lua("local a, b\nreturn a .. b")
end)
it("lua 5.1 compat operators", function()
  config.lua_version = '5.1'
  expect.generate_lua("local a\nreturn ~a", "local a\nreturn bit.bnot(a)")
  expect.generate_lua("local a, b\nreturn a // b", "local a, b\nreturn math.floor(a / b)")
  expect.generate_lua("local a, b\nreturn a ^ b", "local a, b\nreturn math.pow(a, b)")
  expect.generate_lua("local a, b\nreturn a | b", "local a, b\nreturn bit.bor(a, b)")
  expect.generate_lua("local a, b\nreturn a & b", "local a, b\nreturn bit.band(a, b)")
  expect.generate_lua("local a, b\nreturn a ~ b", "local a, b\nreturn bit.bxor(a, b)")
  expect.generate_lua("local a, b\nreturn a << b", "local a, b\nreturn bit.lshift(a, b)")
  expect.generate_lua("local a, b\nreturn a >> b", "local a, b\nreturn bit.rshift(a, b)")
  config.lua_version = '5.3'
end)
it("typed var initialization", function()
  expect.lua_gencode_equals("local a: integer", "local a: integer = 0")
  expect.lua_gencode_equals("local a: boolean", "local a: boolean = false")
  expect.lua_gencode_equals("local a: table", "local a: table = {}")
end)

end)