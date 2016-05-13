defmodule Pocketeer.AuthTest do
  use ExUnit.Case, async: true
  doctest Pocketeer.Auth

  test "returns error if consumer key not given" do
    assert {:ok, _} = Pocketeer.Auth.get_request_token("123", "localhost")
  end
end
