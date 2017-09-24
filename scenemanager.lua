local Object = require "libs/classic/classic"

SceneManager = Object:extend()

function SceneManager:new()
   self.scenes = {}
end

function SceneManager:add(sceneName, scene)
   self.scenes[sceneName] = scene
end

function SceneManager:remove(sceneName)
   if self.scenes[sceneName] == nil then
      return
   end
end

function SceneManager:setCurrent(sceneName)
   SceneManager.current = self.scenes[sceneName]
end

function SceneManager:update(dt)
   if SceneManager.current == nil then
      return
   end
   SceneManager.current:update(dt)
end

function SceneManager:draw()
   if SceneManager.current == nil then
      return
   end
   SceneManager.current:draw()
end

sceneManager = SceneManager()
