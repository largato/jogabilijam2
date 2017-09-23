local Character = require "character"

Loira = Character:extend()

function Loira:new(map, layer, x, y, speed, chartype, name, hp, mp)
   Loira.super.new(self, map, layer, x, y, 3, 2)
   self.speed = speed
   self.type = chartype
   self.name = name
   self.originalHP = hp
   self.originalMP = mp
   self.HP = hp
   self.MP = mp
end

function Loira:load()
   self.sprite:addAnimation('idle', {
      image        = love.graphics.newImage 'assets/images/loira.png',
      frameWidth   = 26,
      frameHeight  = 34,
      stopAtEnd    = false,
      frames       = {
         {1, 1, 4, 1, .4},
      },
   })
end

function Loira:update(dt)
   Loira.super.update(self, dt)
end

return Loira
