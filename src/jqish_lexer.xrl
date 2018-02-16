Definitions.

INT        = [0-9]+
IDENTIFIER = [a-zA-Z_]+
WHITESPACE = [\s\t\n\r]+
OPTIONAL = \?
ITERATOR = \[\]

Rules.

{INT}                   : {token, {int, TokenLine, TokenChars}}.
{IDENTIFIER}            : {token, {identifier, TokenLine, to_binary(TokenChars)}}.
{OPTIONAL}              : {token, {'?', TokenLine}}.
{ITERATOR}              : {token, {iterator, TokenLine}}.
\[                      : {token, {'[', TokenLine}}.
\]                      : {token, {']', TokenLine}}.
\.                      : {token, {'.', TokenLine}}.
:                       : {token, {':', TokenLine}}.
{WHITESPACE}            : skip_token.

Erlang code.

to_binary(Chars) ->
  list_to_binary(Chars).
