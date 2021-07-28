defmodule Jqish do
  @moduledoc """
  Documentation for Jqish.
  """

  defmodule SyntaxError do
    defstruct [:token, before: nil]
  end

  defmodule UnexpectedValueError do
    defstruct [:target, :path]
  end

  defmodule TypeError do
    defstruct [:target, :reason]
  end



  defp lex(rule) do
    rule
    |> to_charlist
    |> :jqish_lexer.string
    |> case do
      {:ok, tokens, _} ->
        {:ok, tokens}
      {:error, {_, _, {_, token}}, _} ->
        {:error, %SyntaxError{token: :erlang.list_to_binary(token)}}
    end
  end

  def parse(rule) do
    with {:ok, tokens} <- lex(rule) do
      case :jqish_parser.parse(tokens) do
        {:ok, _} = ok ->
          ok
        {:error, {_, :jqish_parser, ['syntax error before: ', before]}} ->
          {:error, %SyntaxError{before: :erlang.list_to_binary(before)}}
      end
    end
  end


  defp e(t, {:compose, left, right}) do
    case e(t, left) do
      {:error, _} = e -> e
      res ->
        e(res, right)
    end
  end

  defp e(t, :.), do: t

  defp e(t, {:function, "map", subexpr}) when is_list(t) do
    result = Enum.reduce_while(t, [], fn subvalue, acc ->
      case e(subvalue, subexpr) do
        {:error, _} = err -> {:halt, err}
        :void -> {:cont, acc}
        ok -> {:cont, [ok | acc]}
      end
    end)

    with reversed when is_list(reversed) <- result do
      Enum.reverse(reversed)
    end
  end

  defp e(t, {:function, "map", _subexpr}) do
    {:error, %TypeError{target: t, reason: "Cannot map over a non-list value"}}
  end

  defp e(t, {:function, "select", subexpr}) do
    case e(t, subexpr) do
      true -> t
      false -> :void
    end
  end

  defp e(t, {:operator, op, selector, lhs}) do
    rhs = e(t, selector)
    case op do
      "==" -> rhs == lhs
      ">=" -> rhs >= lhs
      "<=" -> rhs <= lhs
      "!=" -> rhs != lhs
      ">"  -> rhs > lhs
      "<"  -> rhs < lhs
    end
  end

  defp e(t, {:pick, :iterator, rest}) when is_list(t) do
    Enum.map(t, fn el -> e(el, rest) end)
  end
  defp e(t, {:pick, :iterator, _rest}) do
    {:error, %TypeError{target: t, reason: "Cannot iterate over a non-list"}}
  end

  defp e(t, {:pick, tok, {:function, _, _} = f}), do: pick(e(t, f), tok)
  defp e(t, {:pick, tok, rest}), do: e(pick(t, tok), rest)
  defp e(t, nil), do: t

  defp pick(t, nil), do: t
  defp pick(t, {:optional, key}) when is_map(t), do: Map.get(t, key)
  defp pick(_t, {:optional, _key}), do: nil
  defp pick(t, {:slice, from, to}) when is_list(t), do: Enum.slice(t, from, to)
  defp pick(t, index) when is_list(t) and is_integer(index), do: Enum.at(t, index)
  defp pick(t, key) when is_map(t), do: Map.get(t, key)

  defp pick(target, path) do
    {:error, %UnexpectedValueError{target: target, path: path}}
  end


  def eval(target, expr) do
    case e(target, expr) do
      {:error, _} = err -> err
      good -> {:ok, good}
    end
  end

  @doc """
    Run a rule on a target.


  ## Examples

      iex> Jqish.run(%{"foo" => %{"bar" => [1, 2, 3, 4]}}, ".foo.bar.[2]")
      {:ok, 3}
  """
  def run(target, rule) do
    with {:ok, expr} <- parse(rule) do
      eval(target, expr)
    end
  end
end
