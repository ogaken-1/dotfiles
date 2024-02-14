local capabilities = vim.lsp.protocol.make_client_capabilities()

return {
  get = function()
    if true then
      capabilities.textDocument.completion = require('ddc_nvim_lsp').make_client_capabilities().textDocument.completion
    elseif false then
      capabilities.textDocument.completion = require('cmp_nvim_lsp').default_capabilities().textDocument.completion
    end

    return capabilities
  end,
}
