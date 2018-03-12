local b = require("barr")

local lim = 50000
print("Элементов таблицы: ", lim)

collectgarbage(collect)
mem1 = collectgarbage("count")
time1 = os.clock()
local t1 = {}
for i = 1, lim do
  t1[i] = 1
end
time2 = os.clock()
mem2 = collectgarbage("count")
tpic = (mem2 - mem1) * 1024
print("Пиковая память таблицы: ", tpic)

collectgarbage(collect)
mem2 = collectgarbage("count")
tnorm = (mem2 - mem1) * 1024
print("Нормальная память таблицы: ", tnorm)
ttable = time2 - time1
print("Время таблицы: ", ttable)
print("======")

collectgarbage(collect)
mem1 = collectgarbage("count")
time1 = os.clock()
t2 = b:new({8})
for i = 1, lim do
  t2:write({1})
end
time2 = os.clock()
mem2 = collectgarbage("count")
bpic = (mem2 - mem1) * 1024
print("Пиковая память barr: ", bpic)

collectgarbage(collect)
mem2 = collectgarbage("count")
bnorm = (mem2 - mem1) * 1024
print("Нормальная память barr: ", bnorm)
tbarr = time2 - time1
print("Время barr: ", tbarr)
print("======")

if tpic > bpic then print("Выигрыш в пиковом потреблении, раз: ", tpic / bpic)
else print("Проигрыш в пиковом потреблении, раз: ", bpic / tpic) end

if tnorm > bnorm then print("Выигрыш в нормальном потреблении, раз: ", tnorm / bnorm)
else print("Проигрыш в нормальном потреблении, раз: ", bnorm / tnorm) end

if ttable > tbarr then print("Выигрыш во времени, раз: ", ttable / tbarr)
else print("Проигрыш во времени, раз: ", tbarr / ttable) end