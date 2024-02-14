return {
  setup = function()
    local gid = vim.augroup.GetOrAdd 'NvimLspRc'

    vim.autocmd.create('LspAttach', {
      group = gid,
      callback = function(context)
        vim.keymap.set(
          'i',
          '<C-h>',
          vim.lsp.buf.signature_help,
          { buffer = context.buf, desc = 'textDocument/signatureHelp' }
        )

        vim.keymap.set_table {
          mode = 'n',
          opts = {
            buffer = context.buf,
            remap = true,
          },
          maps = {
            { 'K', vim.lsp.buf.hover, { desc = 'textDocument/hover' } },
            { 'gd', vim.lsp.buf.definition, { desc = 'textDocument/definition' } },
            { 'gD', vim.lsp.buf.type_definition, { desc = 'textDocument/typeDefinition' } },
            { 'ma', vim.lsp.buf.code_action, { desc = 'textDocument/codeAction' } },
            { 'mr', vim.lsp.buf.rename, { desc = 'textDocument/rename' } },
            {
              'mf',
              function()
                vim.lsp.buf.format {
                  async = true,
                  filter = function(client)
                    -- I want to use csharpier instead of OmniSharp's document formatting feature.
                    -- But capability request of documentFormattingProvider of OmniSharp seems not working.
                    -- So use filter to don't send formatting request to OmniSharp.
                    return not (client.name:match '^(omnisharp|csharp_ls|tsserver)$')
                  end,
                }
              end,
              { desc = 'textDocument/formatting' },
            },
            { 'gi', '<Plug>(ff-lsp-implementations)', { desc = 'textDocument/implementation*' } },
            { 'gr', '<Plug>(ff-lsp-references)', { desc = 'textDocument/references' } },
            { '<Space>fF', '<Plug>(ff-lsp-workspace-symbols)' },
            {
              ']d',
              function()
                vim.diagnostic.goto_next { float = true }
              end,
              { desc = 'jump to next diagnostic' },
            },
            {
              '[d',
              function()
                vim.diagnostic.goto_prev { float = true }
              end,
              { desc = 'jump to previous diagnostic' },
            },
          },
        }

        vim.autocmd.create('BufWritePre', {
          buffer = context.buf,
          group = 'NvimLspRc',
          callback = function()
            if vim.g.FormatOnSaveEnabled then
              vim.lsp.buf.format { async = false }
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
      end,
    })

    vim.lsp.handlers['textDocument/signatureHelp'] = function(_, results, ctx, config)
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      vim.lsp.handlers.signature_help(
        _,
        results,
        ctx,
        table.extend(config or {}, {
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
        table.extend(config or {}, {
          focusable = false,
          border = 'rounded',
          title = client.name,
          noautocmd = true,
        })
      )
    end

    vim.diagnostic.config {
      virtual_text = false,
      float = {
        border = 'single',
        title = 'diagnostics',
        header = {},
        prefix = function(diag, _, _)
          ---@type string
          local highlight
          if diag.severity == vim.diagnostic.severity.ERROR then
            highlight = 'LspDiagnosticsError'
          elseif diag.severity == vim.diagnostic.severity.WARN then
            highlight = 'LspDiagnosticsWarning'
          elseif diag.severity == vim.diagnostic.severity.INFO then
            highlight = 'LspDiagnosticsInformation'
          elseif diag.severity == vim.diagnostic.severity.HINT then
            highlight = 'LspDiagnosticsHint'
          end

          if diag.code ~= nil then
            return ('%s[%s]: '):format(diag.source, diag.code), highlight
          else
            return ('%s: '):format(diag.source), highlight
          end
        end,
        suffix = '',
        -- source = 'always',
      },
    }

    vim.fn.sign_define {
      {
        name = 'DiagnosticSignError',
        text = ' ',
        texthl = 'DiagnosticSignError',
      },
      {
        name = 'DiagnosticSignWarn',
        text = ' ',
        texthl = 'DiagnosticSignWarn',
      },
      {
        name = 'DiagnosticSignInfo',
        text = ' ',
        texthl = 'DiagnosticSignInfo',
      },
      {
        name = 'DiagnosticSignHint',
        text = ' ',
        texthl = 'DiagnosticSignHint',
      },
    }
  end,
}