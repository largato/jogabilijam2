local Object = require "libs/classic/classic"

SoundManager = Object:extend()

function SoundManager:new()
   self.sounds = {}
end

function SoundManager:add(name, path, static)
   if static then
      self.sounds[name] = love.audio.newSource(path, "static")
   else
      self.sounds[name] = love.audio.newSource(path, "stream")
   end
end

function SoundManager:playLoop(name)
   local source = self.sounds[name]
   source:setLooping(true)
   source:play()
end

function SoundManager:play(name)
   local source = self.sounds[name]
   source:play()
end

function SoundManager:stop(name)
   local source = self.sounds[name]
   source:stop()
end

function SoundManager:stopAll()
   for k, sound in pairs(self.sounds) do
      sound:stop()
   end
end

soundManager = SoundManager()
