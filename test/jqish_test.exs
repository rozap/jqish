defmodule JqishTest do
  use ExUnit.Case
  doctest Jqish

  defp ok({:ok, v}), do: v

  describe "simple evaling" do
    test "simple errors" do
      {:error, error} = Jqish.run(%{"foo" => 1}, ".foo.bar")
      assert error.target == 1
      assert error.path == "bar"

      assert Jqish.run(%{"foo" => 1}, ".this.path.does.not.exist") == {:error, %Jqish.UnexpectedValueError{path: "path", target: nil}}
    end

    test "simple identifers" do
      assert ok(Jqish.run(%{"foo" => 1}, ".foo")) == 1
      assert ok(Jqish.run(%{"foo" => %{"bar" => 1}}, ".foo.bar")) == 1
    end

    test "optional identifers" do
      assert ok(Jqish.run(%{"foo" => "qux"}, ".foo.bar?")) == nil
      assert ok(Jqish.run(%{"foo" => %{"bar" => "qux"}}, ".foo.bar?")) == "qux"
    end

    test "simple indexing" do
      assert ok(Jqish.run([1,2,3,4], ".[0]")) == 1
      assert ok(Jqish.run(%{"foo" => [1, 2, 3, 4, 5]}, ".foo.[2]")) == 3
      assert ok(Jqish.run(%{"foo" => [1, 2, %{"bar" => "qux"}, 4, 5]}, ".foo.[2].bar")) == "qux"
      assert ok(Jqish.run([1, 2, %{"bar" => "qux"}, 4, 5], ".[2].bar")) == "qux"
    end

    test "simple slicing" do
      assert ok(Jqish.run([1, 2, 3, 4, 5], ".[0:2]")) == [1, 2]
      assert ok(Jqish.run(%{"foo" => [1, 2, 3, 4, 5]}, ".foo.[0:2]")) == [1, 2]
    end

    test "simple iteration" do
      assert ok(Jqish.run(
        [%{"foo" => "bar"}, %{"foo" => "qux"}],
        ".[].foo"
      )) == ["bar", "qux"]

      assert ok(Jqish.run(
        [%{"foo" => %{"bar" => 1}}, %{"foo" => %{"bar" => "qux"}}],
        ".[].foo.bar"
      )) == [1, "qux"]

      assert ok(Jqish.run(
        %{"foo" => [%{"bar" => 1}, %{"bar" => "qux"}]},
        ".foo.[].bar"
      )) == [1, "qux"]
    end
  end

  describe "running" do
    test "simple syntax error" do
      {:error, e} = Jqish.run(%{"foo" => "bar"}, "doot!")
      assert e.token == "!"
    end

    test "simple parse error" do
      {:error, _e} = Jqish.run(%{"foo" => "bar"}, ".foo.bar[]")
      # Not really sure about this yet - parser
    end

    test "simple running" do
      assert ok(Jqish.run(%{"foo" => "bar"}, ".foo")) == "bar"
      assert ok(Jqish.run(%{"foo" => %{"bar" => "baz"}}, ".foo.bar")) == "baz"

    end
  end

  describe "boolean expression" do
    test "simple select" do
      assert Jqish.run([1, 2, 3, 4], "map(select(. > 2))") == {:ok, [3, 4]}
    end

    test "nested select" do
      assert Jqish.run([
        %{"id" => "x"},
        %{"id" => "y"},
        %{"id" => "z"}
      ], "map(select(.id == \"y\"))") == {:ok, [%{"id" => "y"}]}
    end

    test "nested select with an index" do
      assert Jqish.run([
        %{"id" => "x"},
        %{"id" => "y"},
        %{"id" => "z"}
      ], "map(select(.id == \"z\"))[0]") == {:ok, %{"id" => "z"}}
    end

    test "nested select with an index and a pick" do
      assert Jqish.run([
        %{"id" => "x"},
        %{"id" => "y"},
        %{"id" => %{"theId" => "z", "nestedKey" => 37}}
      ], "map(select(.id.theId? == \"z\"))[0].id.nestedKey") == {:ok, 37}
    end
  end
end
