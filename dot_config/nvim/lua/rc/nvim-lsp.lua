local function on_attach(context)
  vim.keymap.set(
    'i',
    '<C-h>',
    vim.lsp.buf.signature_help,
    { buffer = context.buf, desc = 'textDocument/signatureHelp' }
  )

  local function on_list(options)
    vim.fn.setloclist(vim.api.nvim_get_current_win(), {}, ' ', options)
    vim.cmd.lfirst()
  end

  vim.keymap.set_table {
    mode = 'n',
    opts = {
      buffer = context.buf,
      remap = true,
    },
    maps = {
      { 'K', vim.lsp.buf.hover, { desc = 'textDocument/hover' } },
      {
        'gd',
        function()
          vim.lsp.buf.definition { on_list = on_list }
        end,
        { desc = 'textDocument/definition' },
      },
      { 'gD', vim.lsp.buf.type_definition, { desc = 'textDocument/typeDefinition' } },
      { 'ma', '<Plug>(lsp-codeAction)', { desc = 'textDocument/codeAction' } },
      { 'mr', vim.lsp.buf.rename, { desc = 'textDocument/rename' } },
      {
        'mf',
        function()
          vim.lsp.buf.format { async = true }
        end,
        { desc = 'textDocument/formatting' },
      },
      { 'gi', '<Plug>(ff-lsp_implementations)', { desc = 'textDocument/implementation*' } },
      { 'gr', '<Plug>(ff-lsp_references)', { desc = 'textDocument/references' } },
    },
  }

  vim.api.nvim_create_autocmd('BufWritePre', {
    buffer = context.buf,
    group = 'VimRc',
    callback = function()
      if vim.g.FormatOnSaveEnabled then
        vim.lsp.buf.format {
          async = false,
          filter = function(client)
            local servers = {
              'tsserver',
              'omnisharp',
            }
            return not vim.list_contains(servers, client.name)
          end,
        }
      end
    end,
  })
  vim.g.FormatOnSaveEnabled = true

  vim.api.nvim_create_user_command('FormatOnSaveEnable', function()
    vim.g.FormatOnSaveEnabled = true
  end, {})
  vim.api.nvim_create_user_command('FormatOnSaveDisable', function()
    vim.g.FormatOnSaveEnabled = false
  end, {})
end

local function apply_window_configs()
  vim.lsp.handlers['textDocument/signatureHelp'] = function(_, results, ctx, config)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    vim.lsp.handlers.signature_help(
      _,
      results,
      ctx,
      vim.tbl_deep_extend('error', config or {}, {
        focusable = false,
        border = 'rounded',
        title = client.name,
        noautocmd = true,
      })
    )
  end

  vim.lsp.handlers['textDocument/hover'] = function(_, results, ctx, config)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    vim.lsp.handlers.hover(
      _,
      results,
      ctx,
      vim.tbl_deep_extend('error', config or {}, {
        focusable = false,
        border = 'rounded',
        title = client.name,
        noautocmd = true,
      })
    )
  end
end

return {
  setup = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = 'VimRc',
      once = true,
      desc = 'nvim-lspのhoverの設定をする',
      callback = apply_window_configs,
    })

    vim.api.nvim_create_autocmd('LspAttach', {
      group = 'VimRc',
      desc = 'nvim-lsp 用のキーマッピングなどを設定する',
      callback = on_attach,
    })
  end,
}
