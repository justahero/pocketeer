defmodule Pocketeer.ClientTest do
  use ExUnit.Case
  import PathHelpers

  doctest Pocketeer.Client

  setup do
    client = Pocketeer.Client.new("1234", "abcd")
    {:ok, client: client}
  end

  test "GET" do
    {:ok, json} = load_json("retrieve_sample.json")
  end
end
