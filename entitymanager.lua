local Object = require "libs/classic/classic"

EntityManager = Object:extend()

function EntityManager:new()
   self.entities = {}
   self.entitiesByType = {}
end

function EntityManager:add(entity)
   self.entities[entity] = true

   if self.entitiesByType[entity.type] == nil then
      self.entitiesByType[entity.type] = {}
   end

   self.entitiesByType[entity.type][entity] = true;
end

function EntityManager:remove(entity)
   if self.entities[entity] == nil then
      return
   end

   self.entities[entity] = nil
   self.entitiesByType[entity.type][entity] = nil
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
end

manager = EntityManager()
