local sodapop = require "libs/sodapop/sodapop"
local Object = require "libs/classic/classic"

Character = Object:extend()

function Character:new(x, y)
   self.x = x
   self.y = y
   self.selected = false
   self.sprite = sodapop.newAnimatedSprite(x, y)
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

function Character:drawSelector(ox, oy)
   local r, g, b, a = love.graphics.getColor()
   local x = self.x + ox
   local y = self.y + oy
   local area = 20
   love.graphics.setColor(255,0,0,64)
   love.graphics.polygon('fill', x-area, y-area, x-area, y+area, x+area, y+area, x+area, y-area)
   love.graphics.setColor(r, g, b, a)
end

return Character
