return {
  filetypes = { 'cs' },
  settings = {
    razor = {
      language_server = {
        cohosting_enabled = false,
      },
    },
    ['csharp|inlay_hints'] = {
      csharp_enable_inlay_hints_for_types = false,
      csharp_enable_inlay_hints_for_implicit_variable_types = false,
      csharp_enable_inlay_hints_for_lambda_parameter_types = false,
      csharp_enable_inlay_hints_for_implicit_object_creation = false,
      dotnet_enable_inlay_hints_for_parameters = true,
      dotnet_enable_inlay_hints_for_literal_parameters = true,
      dotnet_enable_inlay_hints_for_indexer_parameters = false,
      dotnet_enable_inlay_hints_for_object_creation_parameters = true,
      dotnet_enable_inlay_hints_for_other_parameters = true,
      dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
    },
    ['csharp|code_lens'] = {
      dotnet_enable_references_code_lens = true,
      dotnet_enable_tests_code_lens = true,
    },
  },
}
