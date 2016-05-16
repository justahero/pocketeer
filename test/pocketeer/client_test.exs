defmodule Pocketeer.ClientTest do
  use ExUnit.Case, async: false

  import Pocketeer.TestHelpers

  doctest Pocketeer.Client

  test "new without site option" do
    options = %{
      consumer_key: "abcd",
      access_token: "1234"
    }
    assert Pocketeer.Client.new(options)
  end

  test "new with site option" do
    options = %{
      consumer_key: "abcd",
      access_token: "1234",
      site: "localhost"
    }
    assert Pocketeer.Client.new(options)
  end
end
