require "assets"

local sodapop = require "libs/sodapop/sodapop"
local Object = require "libs/classic/classic"
local ActionMenu = require "actionmenu"
local ActionMap = require "actionmap"

Character = Object:extend()

function Character.loadCharFromScript(charName, map, x, y)
   local character = Character(map, x, y)
   local script = io.open("assets/scripts/chars/"..charName:lower()..".char", "r"):read("*all")
   local lines = script:split('\n')
   for lineNum, line in ipairs(lines) do
      local parts = line:split(':')
      local key = parts[1]:lower()
      local value = parts[2]:trim()
      if key=='name' then character.name = value
      elseif key=='hp' then character.HP = tonumber(value); character.originalHP = tonumber(value)
      elseif key=='mp' then character.MP = tonumber(value); character.originalMP = tonumber(value)
      elseif key=='speed' then character.speed = tonumber(value)
      elseif key=='movement' then character.movement = tonumber(value)
      elseif key=='attack' then character.attack = tonumber(value)
      elseif key=='damage' then character.damage = tonumber(value)
      elseif key=='portrait' then character.portrait = love.graphics.newImage(value)
      elseif key=='avatar' then character.avatar = love.graphics.newImage(value)
      elseif key:starts('animation') and map ~= nil then
         local subparts = key:split('.')
         local func = assert(loadstring("return " .. value))
         character.sprite:addAnimation(subparts[2], func())
      end
   end

   if map then
      character:createMaps()
   end

   return character
end


function Character:new(map, x, y)
   self.highlighted = false
   self.selected = false
   self.moving = false -- show move map
   self.attacking = false -- show attack map
   self.moved = false
   self.attacked = false
   if map ~= nil then
      self:setMap(map, x, y)
   end
end

function Character:setMap(map, x, y)
   self.map = map
   self.tileX = math.floor(x / self.map.tilewidth)
   self.tileY = math.floor(y / self.map.tileheight)
   self.x = self.tileX * self.map.tilewidth
   self.y = self.tileY * self.map.tilewidth
   self.sprite = sodapop.newAnimatedSprite(self.x + map.tilewidth / 2, self.y + map.tileheight / 2)
   self.actionMenu = ActionMenu(self, 4, 4, self.map.tilewidth, self.map.tileheight)
end

function Character:createMaps()
   self.moveMap = ActionMap(self.movement, self.tileX, self.tileY, self.map, {0, 255, 255, 64}, {0, 255, 255, 100})
   self.attackMap = ActionMap(self.attack, self.tileX, self.tileY, self.map, {255, 0, 0, 64}, {255, 0, 0, 100})
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

   if self:dead() then
      -- TODO: add death animation
      return
   end

   if self.highlighted then
      self:drawHighlight(ox, oy)
   end
   if self.moving then
      self.moveMap:draw(ox, oy)
   elseif self.attacking then
      self.attackMap:draw(ox, oy)
   elseif self.selected then
      self.actionMenu:draw(ox, oy)
   end
   self.sprite:draw(ox, oy)
end

function Character:moveTo(tileX, tileY)
   self.tileX = tileX
   self.tileY = tileY
   self.x = tileX * self.map.tilewidth
   self.y = tileY * self.map.tileheight
   self.sprite.x = self.x + self.map.tilewidth / 2
   self.sprite.y = self.y + self.map.tileheight / 2
   self:resetUI()
   self.actionMenu:move(self.x, self.y)
   self.actionMenu:select(2)
end

function Character:drawHighlight(ox, oy)
   local r, g, b, a = love.graphics.getColor()
   love.graphics.setColor(255, 0, 0, 64)
   love.graphics.rectangle('fill', self.x - ox, self.y - oy,
                           self.map.tilewidth, self.map.tileheight,
                           self.map.tilewidth / 4, self.map.tileheight / 4)
   love.graphics.setColor(255, 0, 0, 100)
   love.graphics.rectangle('line', self.x - ox, self.y - oy,
                           self.map.tilewidth, self.map.tileheight,
                           self.map.tilewidth / 4, self.map.tileheight / 4)
   love.graphics.setColor(r, g, b, a)
end

-- TODO: move this function somewhere else
function Character:charHit(x, y)
   for entity, v in pairs(manager:getEntities()) do
      if x == entity.tileX and y == entity.tileY then
         return entity
      end
   end
   return nil
end

function Character:moveToTarget()
   if self:actionMap().target.x == self.tileX and self:actionMap().target.y == self.tileY then
      return
   end
   local hit = self:charHit(self:actionMap().target.x, self:actionMap().target.y)
   if hit and not hit:dead() then
      return
   end
   self:moveTo(self:actionMap().target.x, self:actionMap().target.y)
   self.moving = false
   self.moved = true
end

function Character:attackTarget()
   if self:actionMap().target.x == self.tileX and self:actionMap().target.y == self.tileY then
      return
   end

   local hit = self:charHit(self:actionMap().target.x, self:actionMap().target.y)

   if not hit then
      return
   end

   self.attacking = false
   self.attacked = true

   self.actionMenu:select(1)

   hit.HP = hit.HP - self.damage
end

function Character:dead()
   return self.HP <= 0
end

function Character:turnDone()
   return (self.moved and self.attacked) or self:dead()
end

function Character:skip()
   self.highlighted = false
   self.moving = false
   self.attacking = false
   self.moved = true
   self.attacked = true
   self.selected = false
end

function Character:action()
   return self.actionMenu.line
end

function Character:acting()
   return self.moving or self.attacking
end

function Character:unselect()
   self.selected = false
   self.attacking = false
   self.moving = false
   self.moveMap:setTarget(self.tileX, self.tileY)
   self.attackMap:setTarget(self.tileX, self.tileY)
end

function Character:actionMap()
   if self.moving then
      return self.moveMap
   elseif self.attacking then
      return self.attackMap
   end
end

function Character:reset()
   self.selected = false
   self.moving = false
   self.attacking = false
   self.moved = false
   self.attacked = false
   self:resetUI()
end

function Character:resetUI()
   self.actionMenu:select(1)
   self.moveMap:move(self.tileX, self.tileY)
   self.attackMap:move(self.tileX, self.tileY)
   self.moveMap:setTarget(self.tileX, self.tileY)
   self.attackMap:setTarget(self.tileX, self.tileY)
end

return Character
