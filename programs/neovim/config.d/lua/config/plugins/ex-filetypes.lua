local function find_and_open_file(name)
  local switch = require 'config.switch'
  local files = vim
    .iter(vim.fn.systemlist { 'fd', name })
    :filter(function(item)
      return vim.fn.fnamemodify(item, ':t') == name
    end)
    :totable()
  switch(#files)
    :case(1, function()
      local file = files[1]
      vim.cmd.edit(file)
    end)
    :case(0, function()
      vim.notify('File ' .. name .. ' is not found in ' .. vim.fn.getcwd())
    end)
    :default(function()
      local qf_items = {}
      for i, file in ipairs(files) do
        qf_items[i] = {
          filename = file,
          text = file,
        }
      end
      vim.fn.setqflist({}, 'r', { items = qf_items })
      vim.cmd.copen()
    end)
    :eval()
end
return {
  {
    'jlcrochet/vim-razor',
    config = function()
      local function goto_definition()
        local syntax = vim.inspect_pos().syntax
        local hl_group = syntax[#syntax].hl_group
        local cword = vim.fn.expand '<cword>'
        local function is_typename()
          return (hl_group == 'razorRHSIdentifier' or hl_group == 'razorIdentifier')
            and ((vim.fn.expand '<cWORD>'):sub(1, 1) == 'T')
        end
        if
          hl_group == 'razorhtmlTagName'
          or hl_group == 'razorhtmlEndTagName'
          or hl_group == 'razorTypeIdentifier'
          or is_typename()
        then
          find_and_open_file(cword .. '.razor')
        elseif hl_group == 'razorcsRHSIdentifier' then
          vim.cmd.OpenCSharp()
          vim.fn.search(([[\V\<%s\>]]):format(cword))
        else
          vim.cmd.normal { 'gd', bang = true }
        end
      end
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'razor',
        group = vim.api.nvim_create_augroup('config-razor', { clear = true }),
        callback = function()
          vim.keymap.set('n', 'gd', goto_definition, { buffer = true })
        end,
      })
    end,
  },
  {
    'ionide/Ionide-vim',
    ft = 'fsharp',
  },
  { 'hashivim/vim-terraform' },
  { 'direnv/direnv.vim' },
}
