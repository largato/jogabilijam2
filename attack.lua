local sodapop = require "libs/sodapop/sodapop"
local Object = require "libs/classic/classic"

Attack = Object:extend()

function Attack:new(x, y)
   self.sprite = sodapop.newAnimatedSprite(x, y)
   self.sprite:addAnimation('attack', {
     image        = love.graphics.newImage 'assets/images/attack.png',
     frameWidth   = 32,
     frameHeight  = 32,
     stopAtEnd    = true,
     frames       = {
       {1, 1, 8, 1, .08},
     },
   })
   self.sprite:switch('attack')
end

function Attack:draw(ox, oy)
   self.sprite:draw(ox, oy)
end

function Attack:update(dt)
   self.sprite:update(dt)
end

return Attack
