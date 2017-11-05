require "entitymanager"
require "scenemanager"
require "assets"
require "utils"

local Object = require 'libs/classic/classic'
local Character = require 'character'
local Behavior = require "libs/knife/knife/behavior"

local EndScene = require 'endscene'

BattleScene = Object:extend()

function BattleScene:new(camera, map)
   self.map = map
   self.camera = camera

   for k, object in pairs(map.objects) do
      local parts = object.name:split("-")
      local charType = parts[1]
      local charName = parts[2]
      manager:add(Character.loadCharFromScript(charName, map, object.x, object.y), charType)
   end

   self.playerChars = manager:getByType("Player")
   self.cpuChars = manager:getByType("CPU")
   self.charIndex = 0
   self.turn = 1
   self.team = "Player"
end

function BattleScene:init()
   soundManager:stopAll()
   soundManager:playLoop("battle")

   local scaleFactor = settings:screenScaleFactor()
   self.titleFont = assets.fonts.pressstartregular(assets.config.fonts.battleTurnSize * scaleFactor)
   self.charNameFont = assets.fonts.pressstartregular(assets.config.fonts.battleCharNameSize * scaleFactor)
   self.menuItemFont = assets.fonts.pressstartregular(assets.config.fonts.battleCharAttributeSize * scaleFactor)

   self.map:resize(love.graphics.getWidth(), love.graphics.getHeight())
   self:nextChar()
end

function BattleScene:setCamera(c)
   self.camera = c
end

function BattleScene:setMap(m)
   self.map = m
end

function BattleScene:draw()
   local c = self.camera
   c:set()
   self.map:draw(-c.x, -c.y, c.scaleX, c.scaleY)
   manager:draw(0,0)
   manager:drawUI(0,0)
   self:drawHUD(c.x, c.y)
   c:unset()
end

function BattleScene:drawHUD(ox, oy)
   -- Store original graphical settings --
   local oldFont = love.graphics.getFont()
   local r, g, b, a = love.graphics.getColor()

   -- Turn/phase information --
   local teamName = ""
   if self.team == "Player" then
      teamName = "Jogador"
   else
      teamName = "CPU"
   end
   local turnInfo = "Turno "..self.turn.." - "..teamName
   local tunInfoX = love.graphics.getWidth() - self.titleFont:getWidth(turnInfo) - 10
   love.graphics.setFont(self.titleFont)
   love.graphics.setColor(255, 0, 0, 255)
   love.graphics.printf(turnInfo, ox+tunInfoX, oy+10, love.graphics.getWidth(), 'left')

   -- Selected character sheet --
   if self:charSelected() then
      local charSheetX = ox + love.graphics.getWidth() * 0.02
      local charSheetY = oy + love.graphics.getHeight() * 0.75
      local charSheetWidth = love.graphics.getWidth() * 0.25
      local charSheetHeight = love.graphics.getHeight() * 0.23
      local charPicX = charSheetX + (charSheetWidth * 0.05)
      local charPicY = charSheetY + (charSheetHeight * 0.2)
      local charPicWidth = charSheetWidth * 0.4
      local charPicHeight = charSheetHeight * 0.75
      local charNameX = charSheetX + (charSheetWidth * 0.05)
      local charNameY = charSheetY + (charSheetHeight * 0.02)
      local charAttrWidth = (charSheetWidth - charPicWidth) * 0.8
      local charAttrX = charNameX + charPicWidth + (charSheetWidth * 0.02)
      local charHPY = charNameY + (charSheetHeight * 0.2)
      local charMPY = charHPY + (charSheetHeight * 0.2)
      local charName = self:char().name
      local charHP = self:char().HP.."/"..self:char().originalHP
      local charMP = self:char().MP.."/"..self:char().originalMP

      -- character sheet frame --
      love.graphics.setColor(0, 0, 255, 128)
      love.graphics.rectangle('fill', charSheetX, charSheetY, charSheetWidth, charSheetHeight)
      love.graphics.setColor(255, 255, 255, 255)
      -- character avatar --
      love.graphics.setColor(r, g, b, a)
      local avatarXScale = charPicWidth/self:char().avatar:getWidth()
      local avatarYScale = charPicHeight/self:char().avatar:getHeight()
      love.graphics.draw(self:char().avatar, charPicX, charPicY, 0, avatarXScale, avatarYScale)
      -- character name and status --
      love.graphics.setFont(self.charNameFont)
      love.graphics.printf(charName, charNameX, charNameY, charSheetWidth, 'center')
      love.graphics.setFont(self.menuItemFont)
      love.graphics.printf("Vida", charAttrX, charHPY, charAttrWidth, 'left')
      love.graphics.printf(charHP, charAttrX, charHPY, charAttrWidth, 'right')
      love.graphics.printf("Ginga", charAttrX, charMPY, charAttrWidth, 'left')
      love.graphics.printf(charMP, charAttrX, charMPY, charAttrWidth, 'right')
   end
   -- Restore original graphical settings --
   love.graphics.setFont(oldFont)
   love.graphics.setColor(r, g, b, a)
end

function BattleScene:update(dt)
   self.camera:update(dt)
   self.map:update(dt)
   manager:update(dt)
   if self.team == "Enemy" and self.enemyBehavior ~= nil then
      self.enemyBehavior:update(dt)
   end
end

function BattleScene:highlightChar(index)
   if self.charIndex == index then
      return
   end
   self:char(index).highlighted = true
   self.charIndex = index
end

function BattleScene:selectChar(index)
   if self:char() ~= nil then
      self:char().selected = true
   end
end

function BattleScene:unselectChar(index)
   if self:char() ~= nil then
      self:char():unselect()
   end
end

function BattleScene:nextChar()
   if (self:char() and self:char().selected) or self:turnEnded() then
      return
   end

   if self:char() then
      self:char().highlighted = false
   end

   local index = self.charIndex
   repeat
      index = index % table.getn(self:currentTeam()) + 1
   until not self:char(index):turnDone()
   self:highlightChar(index)
   local w, h, flags = love.window.getMode()
   self.camera:panTo(1, self:char().x - w / 2,
                     self:char().y - h / 2)
   self:char():resetUI()
end

function BattleScene:previousChar()
   if (self:char() and self:char().selected) or self:turnEnded() then
      return
   end

   if self:char() then
      self:char().highlighted = false
   end

   local index = self.charIndex
   repeat
      index = (index - 2) % table.getn(self:currentTeam()) + 1
   until not self:char(index):turnDone()
   self:highlightChar(index)
   local w, h, flags = love.window.getMode()
   self.camera:panTo(1, self:char().x - w / 2,
                     self:char().y - h / 2)
end

function BattleScene:setTargetTile(x, y)
   if not self:charSelected() then
      return
   end
   self:char():actionMap():setTarget(x, y)
end

function BattleScene:targetTileUp()
   if not self:charSelected() then
      return
   end
   self:char():actionMap():targetUp()
end

function BattleScene:targetTileDown()
   if not self:charSelected() then
      return
   end
   self:char():actionMap():targetDown()
end

function BattleScene:targetTileLeft()
   if not self:charSelected() then
      return
   end
   self:char():actionMap():targetLeft()
end

function BattleScene:targetTileRight()
   if not self:charSelected() then
      return
   end
   self:char():actionMap():targetRight()
end

function BattleScene:charSelected()
   return self:char() and self:char().selected
end

function BattleScene:charMoving()
   return self:char() and self:char().moving
end

function BattleScene:charAttacking()
   return self:char() and self:char().attacking
end

function BattleScene:move()
   if not self:charSelected() then
      return
   end
   self:char():moveToTarget()

   if self:char():turnDone() then
      self:skip()
   end
end

function BattleScene:select()
   if self.charIndex == 0 then
      return
   end
   self:char().selected = true
end

function BattleScene:attack(skip)
   if not self:charSelected() then
      return
   end
   self:char():attackTarget()

   if self:playerWon() then
      sceneManager:popAndPushScene(EndScene("Jogador"))
      return
   elseif self:enemyWon() then
      sceneManager:popAndPushScene(EndScene("Inimigo"))
      return
   end

   if skip or self:char():turnDone() then
      self:skip()
   end
end

function BattleScene:currentTeam()
   local chars = self.playerChars
   if self.team == "Enemy" then
      chars = self.cpuChars
   end
   return chars
end

function BattleScene:turnEnded()
   for i, char in ipairs(self:currentTeam()) do
      if not char:turnDone() then
         return false
      end
   end
   return true
end

function BattleScene:nextTeam()
   if self.team == "Player" then
      self.team = "Enemy"
      self:startEnemyTurn()
   else
      self.team = "Player"
      self.turn = self.turn + 1
   end
   self:resetChars()
   self:nextChar()
end

function BattleScene:resetChars()
   for i, char in ipairs(self:currentTeam()) do
      char:reset()
   end
end

function BattleScene:skip()
   if not self:char() then
      return
   end
   self:char():skip()
   if self:turnEnded() then
      self:nextTeam()
   else
      self:nextChar()
   end
end

function BattleScene:char(index)
   if self.team == "Player" then
      return self.playerChars[index or self.charIndex]
   else
      return self.cpuChars[index or self.charIndex]
   end
end

function BattleScene:charActing()
   return self:char():acting()
end

function BattleScene:menuUp()
   if not self:charSelected() then
      return
   end
   self:char().actionMenu:menuUp()
end

function BattleScene:menuDown()
   if not self:charSelected() then
      return
   end
   self:char().actionMenu:menuDown()
end

function BattleScene:startEnemyTurn()
   -- TODO: create a different behavior for each enemy type
   self.enemyStates = {
      default = {
         { duration = 0.5 },
         { duration = 0.5, action = BattleScene.enemySelect },
         { duration = 0.5, action = BattleScene.enemySetMoving },
         { duration = 0.5, action = BattleScene.enemySetDestination },
         { duration = 0.5, action = BattleScene.enemyMove, after = 'attack'}
      },
      attack = {
         { duration = 0.5 },
         { duration = 0.5, action = BattleScene.enemySetAttacking },
         { duration = 0.5, action = BattleScene.enemySetAttackTarget },
         { duration = 0.5, action = BattleScene.enemyAttack, after = 'actionEnd' }
      },
      actionEnd = {
         { duration = 0.1, action = BattleScene.enemyCheckEnd }
      }
   }

   self.enemyBehavior = Behavior(self.enemyStates, self)
   self.charIndex = 0
end

function BattleScene:enemySetMoving(scene)
   scene:char().moving = true
end

function BattleScene:enemySetDestination(scene)
   -- choose nearest player character as target
   local targetChar = scene:nearestPlayerChar(scene:char())
   if targetChar == nil then
      return
   end

   local attackMap = scene:char().attackMap.map
   for i, tile in ipairs(attackMap) do
      if tile.x == targetChar.tileX and tile.y == targetChar.tileY then
         return -- don't move if target char is within attack range
      end
   end

   -- now, choose the tile nearest to the target char
   local moveMap = scene:char().moveMap.map
   local minTile = 999999
   local targetTile
   for i, tile in ipairs(moveMap) do
      if (tile.x ~= scene:char().tileX or tile.y ~= scene:char().tileY) and
         (tile.x ~= targetChar.tileX or tile.y ~= targetChar.tileY) and
         not targetChar:charHit(tile.x, tile.y) then -- TODO: remove this function from character class
         local tileDist = manhattan({tile.x, tile.y}, {targetChar.tileX, targetChar.tileY})

         if tileDist < minTile then
            minTile = tileDist
            targetTile = tile
         end
      end
   end

   scene:setTargetTile(targetTile.x, targetTile.y)
end

function BattleScene:nearestPlayerChar(origin)
   local nearest
   local minChar = 999999
   for i, char in ipairs(self.playerChars) do
      if not char:dead() then
         local charDist = manhattan({origin.tileX, origin.tileY},
                                    {char.tileX, char.tileY})
         if charDist < minChar then
            minChar = charDist
            nearest = char
         end
      end
   end
   return nearest
end

function BattleScene:enemySetAttacking(scene)
   scene:char().attacking = true
end

function BattleScene:enemySetAttackTarget(scene)
   -- choose nearest player character as target
   local targetChar = scene:nearestPlayerChar(scene:char())

   -- now, choose the tile nearest to the target char
   local attackMap = scene:char().attackMap.map
   for i, tile in ipairs(attackMap) do
      if tile.x == targetChar.tileX and tile.y == targetChar.tileY then
         scene:setTargetTile(tile.x, tile.y)
         break
      end
   end
end

function BattleScene:enemyMove(scene)
   scene:move()
   if not scene:char().moved then
      -- force character status if the enemy didn't move
      scene:char().moving = false
      scene:char().moved = true
   end
end

function BattleScene:enemyAttack(scene)
   scene:attack(true)
end

function BattleScene:enemyCheckEnd(scene)
   if not scene:turnEnded() then
      scene.enemyBehavior:setState('default', 1)
   else
      scene:nextTeam()
   end
end

function BattleScene:enemySelect(scene)
   if scene:char() == nil then
      scene:nextChar()
   end
   scene:char().selected = true
end

function BattleScene:playerWon()
   return self:teamLost("CPU")
end

function BattleScene:enemyWon()
   return self:teamLost("Player")
end

function BattleScene:teamLost(team)
   for k, char in ipairs(manager:getByType(team)) do
      if not char:dead() then
         return false
      end
   end
   return true
end

function BattleScene:keyPressed(key, scancode,  isRepeat)
   if self.team == "Enemy" then
      return
   end
   if key=="escape" and not isRepeat and self.charIndex ~= 0 then
      self:unselectChar(self.charIndex)
   elseif key=="up" and not isRepeat and self.charIndex ~= 0 then
      if self:charActing() then
         self:targetTileUp()
      else
         self:menuUp();
      end
   elseif key=="down" and not isRepeat and self.charIndex ~= 0 then
      if self:charActing() then
         self:targetTileDown()
      else
         self:menuDown();
      end
   elseif key=="left" and not isRepeat then
      if self:charActing() then
         self:targetTileLeft()
      elseif not self:charSelected() then
         self:previousChar()
      end
   elseif key=="right" and not isRepeat then
      if self:charActing() then
         self:targetTileRight()
      elseif not self:charSelected() then
         self:nextChar()
      end
   elseif key=="return" and not isRepeat and self.charIndex ~= 0 then
      if not self:charSelected() then
         self:select()
      elseif self:charSelected() and not self:charActing() then
         local action = self:char():action()
         if action == 1 then
            self:char().moving = true
         elseif action == 2 then
            self:char().attacking = true
         elseif action == 3 then
            self:skip()
         elseif action == 4 then
            self:unselectChar()
         end
      elseif self:charMoving() then
         self:move()
      elseif self:charAttacking() then
         self:attack()
      end
   end
end

return BattleScene
