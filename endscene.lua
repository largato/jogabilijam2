local Object = require 'libs/classic/classic'

EndScene = Object:extend()

function EndScene:new(team)
   if team == "Jogador" then
      self.message = "Parabéns, você venceu e mostrou quem manda!"
      self.background = love.graphics.newImage('assets/images/bg_intro.png')
   else
      self.message = "Deu ruim, campeão. Só te resta a carreira de empreendedor de palco."
      self.background = love.graphics.newImage('assets/images/bg_defeat.png')
   end
   self.team = team
end

function EndScene:init()
   self.keystrokeCount = 0
end

function EndScene:update(dt)
end

function EndScene:draw(ox, oy)
   local scaleFactor = settings:screenScaleFactor()
   local messageFont = assets.fonts.pressstartregular(assets.config.fonts.creditsTextSize * scaleFactor)

   local oldFont = love.graphics.getFont()
   local r, g, b, a = love.graphics.getColor()

   local scaleX = love.graphics.getWidth() / self.background:getWidth()
   local scaleY = love.graphics.getHeight() / self.background:getHeight()

   love.graphics.draw(self.background, 0, 0, 0, scaleX, scaleY)

   local titleWidth = love.graphics.getWidth() * .6
   local titleX = (love.graphics.getWidth()/2) - (titleWidth/2)
   local titleY = love.graphics.getHeight() * 0.4

   love.graphics.setColor(0,0,0,255)
   love.graphics.setFont(messageFont)
   love.graphics.printf(self.message, titleX, titleY, titleWidth)

   -- restore old graphic settings --
   love.graphics.setFont(oldFont)
   love.graphics.setColor(r,g,b,a)
end

function EndScene:keyPressed(key, scancode,  isRepeat)
   if not isRepeat then
      self.keystrokeCount = self.keystrokeCount + 1
   end
   if (self.keystrokeCount == 2) then
      sceneManager:popScene()
   end
end

return EndScene
