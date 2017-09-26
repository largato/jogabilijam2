function manhattan(p, q)
   assert(#p == #q, 'vectors must have the same length')
   local s = 0
   for i in ipairs(p) do
      s = s + math.abs(p[i] - q[i])
   end
   return s
end
