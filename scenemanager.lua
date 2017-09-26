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
   local scene = self.scenes[sceneName]
   scene:init()
   SceneManager.current = scene
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

function SceneManager:keyPressed(key, scancode, isRepeat)
   SceneManager.current:keyPressed(key, scancode, isRepeat)
end

sceneManager = SceneManager()
