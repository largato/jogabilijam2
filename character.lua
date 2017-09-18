local sodapop = require "libs/sodapop/sodapop"
local Object = require "libs/classic/classic"

Character = Object:extend()

function Character:new(x, y)
   self.x = x
   self.y = y
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
   self.sprite:draw(ox, oy)
end

return Character
