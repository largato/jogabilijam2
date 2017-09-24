local Object = require "libs/classic/classic"

EntityManager = Object:extend()

function EntityManager:new()
   self.entities = {}
   self.entitiesByType = {}
end

function EntityManager:add(entity, entityType)
   self.entities[entity] = true

   if self.entitiesByType[entityType] == nil then
      self.entitiesByType[entityType] = {}
   end

   table.insert(self.entitiesByType[entityType], entity)
end

function EntityManager:remove(entity, entityType)
   if self.entities[entity] == nil then
      return
   end

   self.entities[entity] = nil
   for i, v in ipairs(self.entitiesByType[entityType]) do
      if v == entity then
         table.remove(self.entitiesByType[entityType], i)
         break
      end
   end
end

function EntityManager:getByType(type)
   return self.entitiesByType[type]
end

function EntityManager:getEntities()
   return self.entities
end

function EntityManager:update(dt)
   for entity in pairs(self.entities) do
      entity:update(dt)
   end
end

function EntityManager:draw(ox, oy)
   for entity in pairs(self.entities) do
      entity:draw(ox, oy)
   end
   for entity in pairs(self.entities) do
      entity:drawHUD(ox, oy)
   end
end

manager = EntityManager()
