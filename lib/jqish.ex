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


  defp e(t, []), do: t

  defp e(t, [{:optional, identifier} | rest]) when is_map(t), do: e(Map.get(t, identifier), rest)
  defp e(_not_a_map, [{:optional, _identifier} | _rest]), do: nil


  defp e(t, [{:slice, from, to} | rest]) when is_list(t) do
    e(Enum.slice(t, from, to), rest)
  end

  defp e(t, [:iterator | rest]) when is_list(t) do
    Enum.map(t, fn element -> e(element, rest) end)
  end



  defp e(t, [index | rest]) when is_list(t) and is_integer(index) do
    e(Enum.at(t, index), rest)
  end

  defp e(t, [identifier | rest]) when is_map(t), do: e(Map.get(t, identifier), rest)



  defp e(target, path) do
    {:error, %UnexpectedValueError{target: target, path: path}}
  end

  def eval(target, path) do
    case e(target, path) do
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
    with {:ok, path} <- parse(rule) do
      eval(target, path)
    end
  end
end
