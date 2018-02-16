Nonterminals elems elem.
Terminals '[' ']' '.' '|' '?' ':' int identifier iterator optional.
Rootsymbol elems.

elems -> '.' elem               : ['$2'].
elems -> '.' '[' elem ']'       : ['$3'].


elems -> '.' elem elems         : ['$2' | '$3'].
elems -> '.' '[' elem ']' elems : ['$3' | '$5'].

elem -> elem '?'    : {optional, '$1'}.
elem -> int ':' int : {slice, extract_integer('$1'), extract_integer('$3')}.

elem -> iterator   : iterator.
elem -> int        : extract_integer('$1').
elem -> identifier : extract_token('$1').


Erlang code.

extract_token({_Token, _Line, Value}) -> Value.

extract_integer({_Token, _Line, Value}) -> list_to_integer(Value).
