local function jump_and_show_diagnostic(count)
  return function()
    vim.diagnostic.jump {
      count = count,
      on_jump = function(diagnostic)
        vim.diagnostic.open_float {
          bufnr = diagnostic.bufnr,
          lnum = diagnostic.lnum,
          col = diagnostic.col,
          severity = diagnostic.severity,
          source = diagnostic.source,
          namespace = diagnostic.namespace,
        }
      end,
    }
  end
end

local gid = vim.api.nvim_create_augroup('config-lsp', { clear = false })
vim.api.nvim_create_autocmd('LspAttach', {
  group = gid,
  callback = function(ctx)
    local opts = { buffer = ctx.buf }
    vim.keymap.set('n', 'ma', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    vim.keymap.set('n', 'mr', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
    if vim.fn.maparg('<Plug>(run-format)', 'n') == '' then
      vim.keymap.set('n', '<Plug>(run-format)', function()
        vim.lsp.buf.format { async = true }
      end, opts)
    end
    vim.keymap.set('n', 'gr', '<Plug>(lsp-references)', opts)
    vim.keymap.set('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    vim.keymap.set('n', 'gi', '<Plug>(lsp-implementations)', opts)
    vim.keymap.set('n', ']d', jump_and_show_diagnostic(1), opts)
    vim.keymap.set('n', '[d', jump_and_show_diagnostic(-1), opts)
    vim.keymap.set('n', 'K', function()
      vim.lsp.buf.hover {
        border = 'rounded',
      }
    end, opts)

    if vim.bo[ctx.buf].filetype == 'cs' then
      return
    end
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = gid,
      buffer = ctx.buf,
      callback = function()
        local servers = {
          'vtsls',
          'omnisharp',
          'tsgo',
          'jsonls',
        }
        vim.lsp.buf.format {
          bufnr = ctx.buf,
          filter = function(client)
            for _, server_name in ipairs(servers) do
              if client.name == server_name then
                return false
              end
            end
            return true
          end,
        }
      end,
    })
  end,
})
vim.diagnostic.config {
  float = {
    border = 'rounded',
  },
}
