local Character = require "character"

Saci = Character:extend()

function Saci:new(map, layer, x, y, speed, chartype, name, hp, mp)
   Saci.super.new(self, map, layer, x, y, 2, 1)
   self.speed = speed
   self.type = chartype
   self.name = name
   self.originalHP = hp
   self.originalMP = mp
   self.HP = hp
   self.MP = mp
end

function Saci:load()
   self.sprite:addAnimation('idle', {
      image        = love.graphics.newImage 'assets/images/saci.png',
      frameWidth   = 26,
      frameHeight  = 34,
      stopAtEnd    = false,
      frames       = {
         {1, 1, 4, 1, .4},
      },
   })
end

function Saci:update(dt)
   Saci.super.update(self, dt)
end

return Saci
