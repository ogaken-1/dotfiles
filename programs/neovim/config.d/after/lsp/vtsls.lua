return {
  root_dir = function(bufnr, resolve)
    local found_dirs = vim.fs.find({
      'package.json',
      'tsconfig.json',
      'jsconfig.json',
    }, {
      upward = true,
      path = vim.fs.dirname(vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))),
    })
    if #found_dirs > 0 then
      return resolve(vim.fs.dirname(found_dirs[1]))
    end
  end,
  root_markers = {},
  workspace_required = true,
}
