defmodule JqishTest do
  use ExUnit.Case
  doctest Jqish

  defp ok({:ok, v}), do: v

  describe "simple parsing" do
    test "simple identifier parsing" do
      assert ok(Jqish.parse(".foo")) == ["foo"]
      assert ok(Jqish.parse(".foo.bar")) == ["foo", "bar"]
      assert ok(Jqish.parse(".foo.[\"b-a-r$\"]")) == ["foo", "b-a-r$"]
    end

    test "simple index parsing" do
      assert ok(Jqish.parse(".[7]")) == [7]
      assert ok(Jqish.parse(".[7].[42]")) == [7, 42]
      assert ok(Jqish.parse(".foo.[7]")) == ["foo", 7]
    end

    test "optional identifer parsing" do
      assert ok(Jqish.parse(".foo?")) == [optional: "foo"]
      assert ok(Jqish.parse(".foo.bar?")) == ["foo", optional: "bar"]
    end

    test "iterator parsing" do
      assert ok(Jqish.parse(".[]")) == [:iterator]
      assert ok(Jqish.parse(".[]?")) == [{:optional, :iterator}]
      assert ok(Jqish.parse(".foo.[]")) == ["foo", :iterator]
      assert ok(Jqish.parse(".foo.[].bar.biz")) == ["foo", :iterator, "bar", "biz"]
    end

    test "slice parsing" do
      assert ok(Jqish.parse(".[7:42]")) == [{:slice, 7, 42}]
      assert ok(Jqish.parse(".foo.[7:42].biz")) == ["foo", {:slice, 7, 42}, "biz"]
    end
  end

  describe "simple evaling" do
    test "simple errors" do
      {:error, error} = Jqish.eval(%{"foo" => 1}, ["foo", "bar"])
      assert error.target == 1
      assert error.path == ["bar"]
    end

    test "simple identifers" do
      assert ok(Jqish.eval(%{"foo" => 1}, ["foo"])) == 1
      assert ok(Jqish.eval(%{"foo" => %{"bar" => 1}}, ["foo", "bar"])) == 1
    end

    test "optional identifers" do
      assert ok(Jqish.eval(%{"foo" => "qux"}, ["foo", {:optional, "bar"}])) == nil
      assert ok(Jqish.eval(%{"foo" => %{"bar" => "qux"}}, ["foo", {:optional, "bar"}])) == "qux"
    end

    test "simple indexing" do
      assert ok(Jqish.eval(%{"foo" => [1, 2, 3, 4, 5]}, ["foo", 2])) == 3
      assert ok(Jqish.eval(%{"foo" => [1, 2, %{"bar" => "qux"}, 4, 5]}, ["foo", 2, "bar"])) == "qux"
      assert ok(Jqish.eval([1, 2, %{"bar" => "qux"}, 4, 5], [2, "bar"])) == "qux"
    end

    test "simple slicing" do
      assert ok(Jqish.eval([1, 2, 3, 4, 5], [{:slice, 0, 2}])) == [1, 2]
      assert ok(Jqish.eval(%{"foo" => [1, 2, 3, 4, 5]}, ["foo", {:slice, 0, 2}])) == [1, 2]
    end

    test "simple iteration" do
      assert ok(Jqish.eval(
        [%{"foo" => "bar"}, %{"foo" => "qux"}],
        [:iterator, "foo"]
      )) == ["bar", "qux"]

      assert ok(Jqish.eval(
        [%{"foo" => %{"bar" => 1}}, %{"foo" => %{"bar" => "qux"}}],
        [:iterator, "foo", "bar"]
      )) == [1, "qux"]

      assert ok(Jqish.eval(
        %{"foo" => [%{"bar" => 1}, %{"bar" => "qux"}]},
        ["foo", :iterator, "bar"]
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
end
