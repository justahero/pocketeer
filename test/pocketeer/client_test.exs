defmodule Pocketeer.ClientTest do
  use ExUnit.Case
  import PathHelpers

  doctest Pocketeer.Client

  test "GET" do
    {:ok, json} = load_json("retrieve_sample.json")
  end
end
