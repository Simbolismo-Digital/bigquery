defmodule BigqueryTest do
  use ExUnit.Case
  doctest Bigquery

  test "greets the world" do
    assert Bigquery.hello() == :world
  end
end
