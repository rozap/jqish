Nonterminals expr elem.
Terminals '[' ']' ')' '(' '.' '|' '?' ':' int identifier string iterator optional operator composition function.
Rootsymbol expr.



expr -> expr composition expr   : {compose, '$1', '$3'}.
expr -> '.' operator elem       : extract_operator('$2', '.', '$3').
expr -> expr operator elem      : extract_operator('$2', '$1', '$3').
expr -> function '(' expr ')'   : extract_function('$1', '$3').

expr -> '.'                     : {pick, nil, nil}.
expr -> '.' elem                : {pick, '$2', nil}.
expr -> '.' elem expr           : {pick, '$2', '$3'}.
expr -> expr '[' elem ']'       : {pick, '$3', '$1'}.
expr -> expr '[' elem ']' expr  : {compose, {pick, '$3', '$1'}, '$5'}.

elem -> elem '?'                : {optional, '$1'}.
elem -> int ':' int             : {slice, extract_integer('$1'), extract_integer('$3')}.

elem -> iterator                : iterator.
elem -> int                     : extract_integer('$1').
elem -> identifier              : extract_token('$1').
elem -> string                  : extract_token('$1').


Erlang code.

extract_token({_Token, _Line, Value}) -> Value.
extract_operator({_Token, _Line, Op}, Lhs, Rhs) -> {operator, Op, Lhs, Rhs}.
extract_function({_Token, _Line, Fun}, Expr) -> {function, Fun, Expr}.

extract_integer({_Token, _Line, Value}) -> list_to_integer(Value).
