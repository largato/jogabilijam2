local sodapop = require "libs/sodapop/sodapop"
local Object = require "libs/classic/classic"
local Queue = require "queue"

Character = Object:extend()

function Character:new(map, layer, x, y, movement, attack)
   self.map = map
   self.layer = layer
   self.tileX = math.floor(x / map.tilewidth)
   self.tileY = math.floor(y / map.tileheight)
   self.x = self.tileX * map.tilewidth
   self.y = self.tileY * map.tilewidth
   self.highlighted = false
   self.selected = false
   self.sprite = sodapop.newAnimatedSprite(self.x + map.tilewidth / 2, self.y + map.tileheight / 2)
   self.movement = movement or 3
   self.attack = attack or 1
   self.moveMap = self:actionMap(self.movement)
   self.attackMap = self:actionMap(self.attack)
   self.targetTile = {x=self.tileX, y=self.tileY}
   self.moving = false -- show move map
   self.attacking = false -- show attack map
   self.moved = false
   self.attacked = false
   self:load()
end

function Character:load()
   -- create animations here
end

function Character:update(dt)
   if self.sprite == nil then
      return
   end
   self.sprite:update(dt)
end

function Character:draw(ox, oy)
   if self.sprite == nil then
      return
   end
   if self.highlighted then
      self:drawHighlight(ox, oy)
   end
   if self.moving then
      self:drawMap(ox, oy, self.moveMap, {0, 255, 255, 64}, {0, 255, 255, 100})
      self:drawTargetTile(ox, oy)
   end
   if self.attacking then
      self:drawMap(ox, oy, self.attackMap, {255, 0, 0, 64}, {255, 0, 0, 100})
      self:drawTargetTile(ox, oy)
   end
   self.sprite:draw(ox, oy)
end

function Character:moveTo(tileX, tileY)
   self.tileX = tileX
   self.tileY = tileY
   self.x = tileX * self.map.tilewidth
   self.y = tileY * self.map.tileheight
   self.sprite.x = self.x + self.map.tilewidth / 2
   self.sprite.y = self.y + self.map.tileheight / 2
   self.moveMap = self:actionMap(self.movement)
   self.attackMap = self:actionMap(self.attack)
   self.selected = false
   self.moving = false
   self.targetTile = {x=self.tileX, y=self.tileY}
end

function Character:drawHighlight(ox, oy)
   local r, g, b, a = love.graphics.getColor()
   love.graphics.setColor(255, 0, 0, 64)
   love.graphics.rectangle('fill', self.x - ox, self.y - oy,
                           self.map.tilewidth, self.map.tileheight,
                           self.map.tilewidth / 4, self.map.tileheight / 4)
   love.graphics.setColor(255, 0, 0, 100)
   love.graphics.rectangle('line', self.x - ox, self.y - oy,
                           self.map.tilewidth, self.map.tileheight,
                           self.map.tilewidth / 4, self.map.tileheight / 4)
   love.graphics.setColor(r, g, b, a)
end

function Character:drawTargetTile(ox, oy)
   local r, g, b, a = love.graphics.getColor()
   love.graphics.setColor(255, 0, 0, 150)
   love.graphics.rectangle('fill', self.targetTile.x * self.map.tilewidth - ox,
                           self.targetTile.y * self.map.tileheight - oy,
                           self.map.tilewidth, self.map.tileheight,
                           self.map.tilewidth / 4, self.map.tileheight / 4)
   love.graphics.setColor(255, 0, 0, 200)
   love.graphics.rectangle('line', self.targetTile.x * self.map.tilewidth - ox,
                           self.targetTile.y * self.map.tileheight - oy,
                           self.map.tilewidth, self.map.tileheight,
                           self.map.tilewidth / 4, self.map.tileheight / 4)
   love.graphics.setColor(r, g, b, a)
end

-- run a BFS to draw possible movement positions
-- TODO: check positions for another characters or tiled collidable map objects
function Character:drawMap(ox, oy, map, color, border)
   local r, g, b, a = love.graphics.getColor()

   for i, tile in ipairs(map) do
      love.graphics.setColor(unpack(color))
      love.graphics.rectangle('fill',
                              tile.x * self.map.tilewidth - ox,
                              tile.y * self.map.tileheight - oy,
                              self.map.tilewidth,
                              self.map.tileheight,
                              self.map.tilewidth / 4,
                              self.map.tileheight / 4)

      love.graphics.setColor(unpack(border))
      love.graphics.rectangle('line',
                              tile.x * self.map.tilewidth - ox,
                              tile.y * self.map.tileheight - oy,
                              self.map.tilewidth,
                              self.map.tileheight,
                              self.map.tilewidth / 4,
                              self.map.tileheight / 4)
   end

   love.graphics.setColor(r, g, b, a)
end

function Character:actionMap(distance)
   local q = Queue() -- bfs queue
   q:push({x=self.tileX, y=self.tileY})

   local d = {} -- distance map
   d[self.tileX] = {}
   d[self.tileX][self.tileY] = 0

   local moveMap = {}
   table.insert(moveMap, {x=self.tileX, y=self.tileY})

   local function tadd(q, d, tile, newTile)
      if d[newTile.x] == nil or d[newTile.x][newTile.y] == nil then
         if d[newTile.x] == nil then
            d[newTile.x] = {}
         end

         d[newTile.x][newTile.y] = d[tile.x][tile.y] + 1

         if d[newTile.x][newTile.y] <= distance then
            table.insert(moveMap, {x=newTile.x, y=newTile.y})
            q:push({x=newTile.x, y=newTile.y})
         end
      end
   end

   while not q:empty() do
      local tile = q:pop()
      if tile.x >= 0 and tile.y >= 0 and tile.x <= self.map.width and tile.y <= self.map.height then
         tadd(q, d, tile, {x=tile.x - 1, y = tile.y})
         tadd(q, d, tile, {x=tile.x + 1, y = tile.y})
         tadd(q, d, tile, {x=tile.x, y = tile.y - 1})
         tadd(q, d, tile, {x=tile.x, y = tile.y + 1})
      end
   end

   return moveMap
end

function Character:moveToTarget()
   if self.targetTile.x == self.tileX and self.targetTile.y == self.tileY then
      return
   end
   self:moveTo(self.targetTile.x, self.targetTile.y)
end

function Character:attackTarget()
   if self.targetTile.x == self.tileX and self.targetTile.y == self.tileY then
      return
   end
   -- TODO: attack and unset attacking property
end

function Character:targetExists(target)
   local map = nil
   if self.moving then
      map = self.moveMap
   else
      map = self.attackMap
   end
   for i, tile in ipairs(map) do
      if tile.x == target.x and tile.y == target.y then
         return true
      end
   end
   return false
end

function Character:targetTileUp()
   local newTarget = {x=self.targetTile.x, y=self.targetTile.y - 1}
   if self:targetExists(newTarget) then
      self.targetTile = newTarget
   end
end

function Character:targetTileDown()
   local newTarget = {x=self.targetTile.x, y=self.targetTile.y + 1}
   if self:targetExists(newTarget) then
      self.targetTile = newTarget
   end
end

function Character:targetTileLeft()
   local newTarget = {x=self.targetTile.x - 1, y=self.targetTile.y}
   if self:targetExists(newTarget) then
      self.targetTile = newTarget
   end
end

function Character:targetTileRight()
   local newTarget = {x=self.targetTile.x + 1, y=self.targetTile.y}
   if self:targetExists(newTarget) then
      self.targetTile = newTarget
   end
end

return Character
