Character = require "character"

SampleChar = Character:extend()

function SampleChar:new(x, y, speed)
   SampleChar.super.new(self, x, y)
   self.speed = speed
   self.type = "SampleChar"
end

function SampleChar:load()
   self.sprite:addAnimation('idle', {
      image        = love.graphics.newImage 'assets/images/green_valley_character_assets.png',
      frameWidth   = 32,
      frameHeight  = 32,
      stopAtEnd    = true,
      frames       = {
         {2, 1, 2, 1, .2},
      },
   })

   self.sprite:addAnimation('walkingRight', {
      image        = love.graphics.newImage 'assets/images/green_valley_character_assets.png',
      frameWidth   = 32,
      frameHeight  = 32,
      frames       = {
         {1, 3, 3, 3, .2},
      },
   })

   self.sprite:addAnimation('walkingLeft', {
      image        = love.graphics.newImage 'assets/images/green_valley_character_assets.png',
      frameWidth   = 32,
      frameHeight  = 32,
      frames       = {
         {1, 2, 3, 2, .2},
      },
   })

   self.sprite:addAnimation('walkingUp', {
      image        = love.graphics.newImage 'assets/images/green_valley_character_assets.png',
      frameWidth   = 32,
      frameHeight  = 32,
      frames       = {
         {1, 4, 3, 4, .2},
      },
   })

   self.sprite:addAnimation('walkingDown', {
      image        = love.graphics.newImage 'assets/images/green_valley_character_assets.png',
      frameWidth   = 32,
      frameHeight  = 32,
      frames       = {
         {1, 1, 3, 1, .2},
      },
   })
end

function SampleChar:update(dt)
   SampleChar.super.update(self, dt)
end

return SampleChar
