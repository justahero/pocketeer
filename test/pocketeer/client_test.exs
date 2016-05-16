defmodule Pocketeer.ClientTest do
  use ExUnit.Case, async: false

  import Pocketeer.TestHelpers

  doctest Pocketeer.Client

  setup do
    server = Bypass.open
    client = build_client(%{site: bypass_server(server)})
    {:ok, server: server, client: client}
  end

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

  test "get", %{server: server, client: client} do
    bypass server, "POST", "/v3/get", fn conn ->
      json_response(conn, 200, "retrieve_sample.json")
    end

    {:ok, _json} = Pocketeer.Client.get(client)
  end
end
