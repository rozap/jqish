# Jqish

Usage
```elixir
Jqish.run(%{"foo" => %{"bar" => [1, 2, 3, 4]}}, ".foo.bar.[2]")
{:ok, 3}
```

## Installation
Get it from hex

```elixir
def deps do
  [
    {:jqish, "~> 0.1.0"}
  ]
end
```


