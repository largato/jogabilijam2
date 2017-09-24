local Object = require "libs/classic/classic"
local Queue = require "queue"

ActionMap = Object:extend()

function ActionMap:new(distance, tileX, tileY, map, tileColor, borderColor)
   self.tileX = tileX
   self.tileY = tileY
   self.target = {x=tileX, y=tileY}
   self.tileColor = tileColor
   self.borderColor = borderColor
   self.tileWidth = map.tilewidth
   self.tileHeight = map.tileheight
   self.mapWidth = map.width
   self.mapHeight = map.height
   self.hitLayer = map.layers["Hitboxes"]
   self.distance = distance
   self:updateMap(distance)
end

function ActionMap:draw(ox, oy)
   self:drawMap(ox, oy)
   self:drawTargetTile(ox, oy)
end

function ActionMap:setTarget(x, y)
   self.target = {x=x, y=y}
end

function ActionMap:move(x, y)
   self.tileX = x
   self.tileY = y
   self:updateMap(self.distance)
end

function ActionMap:drawTargetTile(ox, oy)
   local r, g, b, a = love.graphics.getColor()

   love.graphics.setColor(255, 0, 0, 150)
   love.graphics.rectangle('fill', self.target.x * self.tileWidth - ox,
                           self.target.y * self.tileHeight - oy,
                           self.tileWidth, self.tileHeight,
                           self.tileWidth / 4, self.tileHeight / 4)

   love.graphics.setColor(255, 0, 0, 200)

   love.graphics.rectangle('line', self.target.x * self.tileWidth - ox,
                           self.target.y * self.tileHeight - oy,
                           self.tileWidth, self.tileHeight,
                           self.tileWidth / 4, self.tileHeight / 4)

   love.graphics.setColor(r, g, b, a)
end

function ActionMap:drawMap(ox, oy)
   local r, g, b, a = love.graphics.getColor()

   for i, tile in ipairs(self.map) do
      love.graphics.setColor(unpack(self.tileColor))
      love.graphics.rectangle('fill',
                              tile.x * self.tileWidth - ox,
                              tile.y * self.tileHeight - oy,
                              self.tileWidth,
                              self.tileHeight,
                              self.tileWidth / 4,
                              self.tileHeight / 4)

      love.graphics.setColor(unpack(self.borderColor))

      love.graphics.rectangle('line',
                              tile.x * self.tileWidth - ox,
                              tile.y * self.tileHeight - oy,
                              self.tileWidth,
                              self.tileHeight,
                              self.tileWidth / 4,
                              self.tileHeight / 4)
   end

   love.graphics.setColor(r, g, b, a)
end

-- run a BFS to create a map with possible target positions
function ActionMap:updateMap(distance)
   local q = Queue() -- bfs queue
   q:push({x=self.tileX, y=self.tileY})

   local d = {} -- distance map
   d[self.tileX] = {}
   d[self.tileX][self.tileY] = 0

   self.map = {}
   table.insert(self.map, {x=self.tileX, y=self.tileY})

   local function tadd(q, d, tile, newTile)
      if d[newTile.x] == nil or d[newTile.x][newTile.y] == nil then
         if d[newTile.x] == nil then
            d[newTile.x] = {}
         end

         d[newTile.x][newTile.y] = d[tile.x][tile.y] + 1

         if d[newTile.x][newTile.y] <= distance and not self:layerHit(newTile.x+1, newTile.y+1) then
            table.insert(self.map, {x=newTile.x, y=newTile.y})
            q:push({x=newTile.x, y=newTile.y})
         end
      end
   end

   while not q:empty() do
      local tile = q:pop()
      if tile.x >= 0 and tile.y >= 0 and tile.x <= self.mapWidth and tile.y <= self.mapHeight then
         tadd(q, d, tile, {x=tile.x - 1, y = tile.y})
         tadd(q, d, tile, {x=tile.x + 1, y = tile.y})
         tadd(q, d, tile, {x=tile.x, y = tile.y - 1})
         tadd(q, d, tile, {x=tile.x, y = tile.y + 1})
      end
   end
end

function ActionMap:layerHit(x, y)
   return self.hitLayer.data[y] ~= nil and self.hitLayer.data[y][x] ~= nil
end

function ActionMap:targetUp()
   local newTarget = {x=self.target.x, y=self.target.y - 1}
   if self:targetExists(newTarget) then
      self.target = newTarget
   end
end

function ActionMap:targetDown()
   local newTarget = {x=self.target.x, y=self.target.y + 1}
   if self:targetExists(newTarget) then
      self.target = newTarget
   end
end

function ActionMap:targetLeft()
   local newTarget = {x=self.target.x - 1, y=self.target.y}
   if self:targetExists(newTarget) then
      self.target = newTarget
   end
end

function ActionMap:targetRight()
   local newTarget = {x=self.target.x + 1, y=self.target.y}
   if self:targetExists(newTarget) then
      self.target = newTarget
   end
end

function ActionMap:targetExists(target)
   for i, tile in ipairs(self.map) do
      if tile.x == target.x and tile.y == target.y then
         return true
      end
   end
   return false
end

return ActionMap
