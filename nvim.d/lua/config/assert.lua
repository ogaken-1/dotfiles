local assert = {}

---@param x any
---@return string
function assert.string(x)
  if type(x) ~= 'string' then
    error 'Value must be a string.'
  end
  return x
end

return assert
