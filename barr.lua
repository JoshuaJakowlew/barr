local barr = {}

function barr:new(chunk)
  local obj = {
    data = {},
    chunk = {},
    chunkSize = 0,
    maxChunkSize = 64,
    size = 0,
    cellCapacity = 0
  }
  
  if type(chunk) == "number" then
    if chunk > obj.maxChunkSize then return nil end
    obj.chunk[1] = chunk
    obj.chunkSize = chunk
  elseif type(chunk) == "table" then
    local size = 0
    
    for i = 1, #chunk do
      if tonumber(chunk[i]) == nil then return nil end
      size = size + chunk[i]
    end
    
    if size > obj.maxChunkSize then return nil end
    obj.chunk = chunk
    obj.chunkSize = size
  else
    return nil
  end
  
  obj.cellCapacity = obj.maxChunkSize // obj.chunkSize
  
  self.__index = self
  return setmetatable(obj, self)
end

-- Calculates integer power
function barr:pow(x, y)
  if y == 0 then return 1 end
  local oldX = x
  for i = 0, y - 2 do
    x = x * oldX
  end
  return x
end

-- Calculates power of 2
function barr:pow2(x)
  return 1 << x
end

function barr:write(chunk)
  if chunk == nil then return nil end
  
  if self.size % self.cellCapacity == 0 then
    self.data[#self.data + 1] = 0
  end
  
  -- Calculate bit before write position
  local startBit = self.maxChunkSize - self.size % self.cellCapacity * self.chunkSize
  local cell = 0
  
  for i = 1, #chunk do
    -- Clear non used bits
    chunk[i] = chunk[i] & (barr:pow2(self.chunk[i]) - 1)
    -- Shift bits to the right place
    chunk[i] = chunk[i] << (startBit - self.chunk[i])
    -- Add data to cell
    cell = cell | chunk[i]
    -- Add written bits
    startBit = startBit - self.chunk[i]
  end
  
  self.data[#self.data] = self.data[#self.data] | cell
  self.size = self.size + 1
end

function barr:read(pos)
  if pos == nil or pos < 0 or pos >= self.size then return nil end
  
  -- Get needed cell
  local cell = self.data[pos // self.cellCapacity + 1]
  -- Prepare chunk
  local chunk = {}
  -- Calculate bit before write position
  local startBit = self.maxChunkSize - pos % self.cellCapacity * self.chunkSize
  
  for i = 1, #self.chunk do
    -- Clear non used bits
    chunk[i] = barr:pow2(self.chunk[i]) - 1
    -- Shift bits to the stored place
    chunk[i] = chunk[i] << (startBit - self.chunk[i])
    -- Add data to chunk
    chunk[i] = cell & chunk[i]
    -- Shift bits back
    chunk[i] = chunk[i] >> (startBit - self.chunk[i])
    -- Add written bits
    startBit = startBit - self.chunk[i]
  end
  
  return chunk
end

function barr:writeArray(array)
  for i = 1, #array do
    self:write(array[i])
  end
end

function barr:readArray(pos, n)
  local t = {}
  for i = pos, n - 1 do
    t[i+1] = self:read(i)
  end
  return t
end

return barr