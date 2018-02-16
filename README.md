# Jqish

Usage
```elixir
Jqish.run(%{"foo" => %{"bar" => [1, 2, 3, 4]}}, ".foo.bar.[2]")
{:ok, 3}
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `jqish` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:jqish, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/jqish](https://hexdocs.pm/jqish).

