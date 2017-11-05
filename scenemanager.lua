local Object = require "libs/classic/classic"

local Stack = require "stack"

SceneManager = Object:extend()

function SceneManager:new()
   self.sceneStack = Stack()
end

function SceneManager:initCurrentScene()
   if self.sceneStack:size() > 0 then
      self.sceneStack:peek():init()
   end
end

function SceneManager:pushScene(newScene)
   self.sceneStack:push(newScene)
   self:initCurrentScene()
end

function SceneManager:popScene()
   self.sceneStack:pop()
   self:initCurrentScene()
end

function SceneManager:popAndPushScene(newScene)
   self.sceneStack:pop()
   self.sceneStack:push(newScene)
   self:initCurrentScene()
end

function SceneManager:printSceneStack()
   print("Scene stack:")
   self.sceneStack:print()
end

function SceneManager:update(dt)
   if self.sceneStack:size() == 0 then
      return
   end
   self.sceneStack:peek():update(dt)
end

function SceneManager:draw()
   if self.sceneStack:size() == 0 then
      return
   end
   self.sceneStack:peek():draw()
end

function SceneManager:keyPressed(key, scancode, isRepeat)
   if self.sceneStack:size() == 0 then
      return
   end
   self.sceneStack:peek():keyPressed(key, scancode, isRepeat)
end

sceneManager = SceneManager()
