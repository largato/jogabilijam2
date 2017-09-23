local Character = require "character"

Cidadao = Character:extend()

function Cidadao:new(map, layer, x, y, speed, chartype, name, hp, mp)
   Cidadao.super.new(self, map, layer, x, y, 1, 5)
   self.speed = speed
   self.type = chartype
   self.name = name
   self.originalHP = hp
   self.originalMP = mp
   self.HP = hp
   self.MP = mp
end

function Cidadao:load()
   self.sprite:addAnimation('idle', {
      image        = love.graphics.newImage 'assets/images/homidebem.png',
      frameWidth   = 26,
      frameHeight  = 34,
      stopAtEnd    = false,
      frames       = {
         {1, 1, 4, 1, .4},
      },
   })
end

function Cidadao:update(dt)
   Cidadao.super.update(self, dt)
end

return Cidadao
