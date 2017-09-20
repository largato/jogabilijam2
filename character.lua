local sodapop = require "libs/sodapop/sodapop"
local Object = require "libs/classic/classic"

Character = Object:extend()

function Character:new(map, layer, x, y)
   self.map = map
   self.layer = layer
   self.tileX = math.floor(x / map.tilewidth)
   self.tileY = math.floor(y / map.tileheight)
   self.x = self.tileX * map.tilewidth
   self.y = self.tileY * map.tilewidth
   self.selected = false
   self.sprite = sodapop.newAnimatedSprite(self.x + map.tilewidth / 2, self.y + map.tileheight / 2)
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
   if self.selected then
      self:drawSelector(ox, oy)
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
end

function Character:drawSelector(ox, oy)
   local r, g, b, a = love.graphics.getColor()
   love.graphics.setColor(255,0,0,64)
   love.graphics.rectangle('fill', self.x - ox, self.y - oy, self.map.tilewidth, self.map.tileheight)
   love.graphics.setColor(r, g, b, a)
end

return Character
