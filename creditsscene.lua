require 'assets'

local Object = require 'libs/classic/classic'

CreditsScene = Object:extend()

function CreditsScene:new()
end

function CreditsScene:init()
   local scaleFactor = settings:screenScaleFactor()
   self.titleFont = assets.fonts.pressstartregular(assets.config.fonts.creditsTitleSize * scaleFactor)
   self.subtitleFont = assets.fonts.pressstartregular(assets.config.fonts.creditsSubtitleSize * scaleFactor)
   self.textFont = assets.fonts.pressstartregular(assets.config.fonts.creditsTextSize * scaleFactor)
   self.keystrokeCount = 0
   self.background = love.graphics.newImage('assets/images/bg_intro.png')
   self.titleColor = {255, 255, 255, 255}
   self.subtitleColor = {255, 255, 255, 255}
   self.textColor = {0, 0, 107, 255}
end

function CreditsScene:update(dt)
   
end

function CreditsScene:draw()
   -- store current graphic settings --
   local oldFont = love.graphics.getFont()
   local r, g, b, a = love.graphics.getColor()

   -- background --
   local bgXScale = love.graphics.getWidth()/self.background:getWidth()
   local bgYScale = love.graphics.getHeight()/self.background:getHeight()
   love.graphics.draw(self.background, 0, 0, 0, bgXScale, bgYScale)

   -- render static credits --
   love.graphics.setColor(unpack(self.titleColor))
   love.graphics.setFont(self.titleFont)
   local title = "Créditos"
   local titleWidth = self.titleFont:getWidth(title)
   local titleX = (love.graphics.getWidth()/2) - (titleWidth/2)
   local titleY = love.graphics.getHeight() * 0.1
   love.graphics.printf(title, titleX, titleY, titleWidth)

   -- Programming --
   love.graphics.setColor(unpack(self.subtitleColor))
   love.graphics.setFont(self.subtitleFont)
   local programming = "Programação"
   local programmingX = love.graphics.getWidth() * 0.1
   local programmingY = love.graphics.getHeight() * 0.3
   local programmingWidth = self.subtitleFont:getWidth(programming)
   love.graphics.printf(programming, programmingX, programmingY, programmingWidth)

   love.graphics.setColor(unpack(self.textColor))
   love.graphics.setFont(self.textFont)
   local roger = "Roger Zanoni"
   local rogerX = love.graphics.getWidth() * 0.1
   local rogerY = love.graphics.getHeight() * 0.35
   local rogerWidth = self.textFont:getWidth(roger)
   love.graphics.printf(roger, rogerX, rogerY, rogerWidth)

   local luiz = "Luiz Cavalcanti"
   local luizX = love.graphics.getWidth() * 0.1
   local luizY = love.graphics.getHeight() * 0.4
   local luizWidth = self.textFont:getWidth(luiz)
   love.graphics.printf(luiz, luizX, luizY, luizWidth)

   -- Art --
   love.graphics.setColor(unpack(self.subtitleColor))
   love.graphics.setFont(self.subtitleFont)
   local art = "Arte"
   local artX = love.graphics.getWidth() * 0.6
   local artY = love.graphics.getHeight() * 0.3
   local artWidth = self.subtitleFont:getWidth(art)
   love.graphics.printf(art, artX, artY, artWidth)

   love.graphics.setColor(unpack(self.textColor))
   love.graphics.setFont(self.textFont)
   local diogo = "Diogo Souza"
   local diogoX = love.graphics.getWidth() * 0.6
   local diogoY = love.graphics.getHeight() * 0.35
   local diogoWidth = self.textFont:getWidth(diogo)
   love.graphics.printf(diogo, diogoX, diogoY, diogoWidth)

   rogerX = love.graphics.getWidth() * 0.6
   rogerY = love.graphics.getHeight() * 0.4
   love.graphics.printf(roger, rogerX, rogerY, rogerWidth)

   luizX = love.graphics.getWidth() * 0.6
   luizY = love.graphics.getHeight() * 0.45
   love.graphics.printf(luiz, luizX, luizY, luizWidth)

   local oga = "OpenGameArt.org"
   local ogaX = love.graphics.getWidth() * 0.6
   local ogaY = love.graphics.getHeight() * 0.5
   local ogaWidth = self.textFont:getWidth(oga)
   love.graphics.printf(oga, ogaX, ogaY, ogaWidth)

   -- Music --
   love.graphics.setColor(unpack(self.subtitleColor))
   love.graphics.setFont(self.subtitleFont)
   local music = "Musica"
   local musicX = love.graphics.getWidth() * 0.1
   local musicY = love.graphics.getHeight() * 0.7
   local musicWidth = self.subtitleFont:getWidth(music)
   love.graphics.printf(music, musicX, musicY, musicWidth)

   love.graphics.setColor(unpack(self.textColor))
   love.graphics.setFont(self.textFont)
   ogaX = love.graphics.getWidth() * 0.1
   ogaY = love.graphics.getHeight() * 0.75
   love.graphics.printf(oga, ogaX, ogaY, ogaWidth)

   -- Level design --
   love.graphics.setColor(unpack(self.subtitleColor))
   love.graphics.setFont(self.subtitleFont)
   local level = "Level design"
   local levelX = love.graphics.getWidth() * 0.6
   local levelY = love.graphics.getHeight() * 0.7
   local levelWidth = self.subtitleFont:getWidth(level)
   love.graphics.printf(level, levelX, levelY, levelWidth)

   love.graphics.setColor(unpack(self.textColor))
   love.graphics.setFont(self.textFont)
   rogerX = love.graphics.getWidth() * 0.6
   rogerY = love.graphics.getHeight() * 0.75
   love.graphics.printf(roger, rogerX, rogerY, rogerWidth)

   -- restore old graphic settings --
   love.graphics.setFont(oldFont)
   love.graphics.setColor(r,g,b,a)
end

function CreditsScene:keyPressed(key, code, isRepeat)
   if not isRepeat then
      self.keystrokeCount = self.keystrokeCount + 1
   end
   if (self.keystrokeCount == 2) then
      sceneManager:popScene()
   end
end

return CreditsScene
