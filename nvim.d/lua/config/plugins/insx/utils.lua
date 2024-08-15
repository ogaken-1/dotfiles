local M = {}

---@param node? TSNode
---@param node_type string
---@return boolean
function M.in_node_recursive(node, node_type)
  return (node ~= nil) and ((node:type() == node_type) or M.in_node_recursive(node:parent(), node_type))
end
---@param node_type string
---@return boolean
function M.in_node(node_type)
  return M.in_node_recursive(vim.treesitter.get_node(), node_type)
end

---@param lines string|string[]
---@return insx.RecipeSource
function M.snippet_recipe(lines)
  if type(lines) == 'table' then
    lines = table.concat(lines, '\n')
  end
  return {
    action = function(ctx)
      ctx.send '<C-w>'
      vim.snippet.expand(lines)
    end,
  }
end

---@param x insx.RecipeSource | fun(ctx: insx.Context) | string
---@return insx.RecipeSource
function M.normalize(x)
  if type(x) == 'function' then
    return { action = x }
  elseif type(x) == 'string' then
    return {
      action = function(ctx)
        ctx.send(x)
      end,
    }
  elseif type(x) == 'table' then
    return x
  else
    error('Unexpected type: ' .. type(x))
  end
end

M.left = '<C-g>U<Left>'

return M
