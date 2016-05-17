defmodule Pocketeer.ClientTest do
  use ExUnit.Case, async: false

  doctest Pocketeer.Client

  test "new without site option" do
    options = %{
      consumer_key: "abcd",
      access_token: "1234"
    }
    client = Pocketeer.Client.new(options)
    assert "abcd" == client.consumer_key
    assert "1234" == client.access_token
    assert "https://getpocket.com" == client.site
  end

  test "new with site option" do
    options = %{
      consumer_key: "abcd",
      access_token: "1234",
      site: "localhost"
    }
    client = Pocketeer.Client.new(options)
    assert "abcd" == client.consumer_key
    assert "1234" == client.access_token
    assert "localhost" == client.site
  end
end
