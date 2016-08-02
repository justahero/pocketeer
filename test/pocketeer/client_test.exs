defmodule Pocketeer.ClientTest do
  use ExUnit.Case, async: false

  doctest Pocketeer.Client

  setup do
    Application.delete_env(:pocketeer, :pocket_url)
  end

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

  test "sets site via Application env" do
    Application.put_env(:pocketeer, :pocket_url, "localhost")
    options = %{consumer_key: "abcd", access_token: "1234"}
    client  = Pocketeer.Client.new(options)
    assert "localhost" == client.site
  end
end
