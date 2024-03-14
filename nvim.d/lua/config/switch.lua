---@class config.Switch<T>
---@field case fun(self: config.Switch, pat: any, cb: fun(T)): config.Switch
---@field default fun(self: config.Switch, cb: fun(T)): config.Switch
---@field eval fun(self: config.Switch)

---@param x any
---@return config.Switch
local function switch(x)
  return {
    ---@private
    cases = {},
    ---@private
    default_case = nil,
    case = function(self, pattern, _then)
      self.cases[#self.cases + 1] = function()
        if (not self.matched) and x == pattern then
          self.matched = true
          return _then(x)
        end
      end
      return self
    end,
    default = function(self, _then)
      self.default_case = function()
        if not self.matched then
          return _then(x)
        end
      end
      return self
    end,
    eval = function(self)
      for _, case in ipairs(self.cases) do
        local value = case()
        if value ~= nil then
          return value
        end
      end
      if self.default_case ~= nil then
        return self.default_case()
      end
    end,
  }
end

return switch
