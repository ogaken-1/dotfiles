namespace {{_expr_:g:CSNamespace('%')}};

public {{_expr_:expand('%')->fnamemodify(':t') =~# '^I[A-Z]' ? 'interface' : 'sealed class'}} {{_expr_:g:CSClassName('%')}}
{
    {{_cursor_}}
}
