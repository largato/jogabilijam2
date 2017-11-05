local Object = require 'libs/classic/classic'

local Timer = require 'libs/knife/knife/timer'

local MenuScene = require 'menuscene'

IntroScene = Object:extend()

local DEFAULT_INTERVAL = 3

function IntroScene:new()
end

function IntroScene:init()
   self.currentSlide = 0
   self.slides = {}
   largato_logo = love.graphics.newImage('assets/images/largato_logo_white.png')
   table.insert(self.slides, largato_logo)
   love_logo = love.graphics.newImage('assets/images/love_logo.png')
   table.insert(self.slides, love_logo)
   self:nextSlide()
end

function IntroScene:update(dt)
   Timer.update(dt)
end

function IntroScene:draw()
   if self.currentSlide > 0 then
      local logo = self.slides[self.currentSlide]
      local x = (love.graphics.getWidth() / 2) - (logo:getWidth()/2)
      local y = (love.graphics.getHeight() / 2) - (logo:getHeight()/2)
      love.graphics.draw(logo, x, y)
   end
end

function IntroScene:keyPressed(key, code, isRepeat)
end

function IntroScene:startTimer()
   Timer.after(DEFAULT_INTERVAL, function() self:nextSlide() end)
end

function IntroScene:nextSlide()
   if self.currentSlide < #self.slides then
      self.currentSlide = self.currentSlide+1
      self:startTimer()
   else
      sceneManager:popAndPushScene(MenuScene())
   end
end

return IntroScene
