defmodule Pocketeer.ClientTest do
  use ExUnit.Case
  import Pocketeer.TestHelpers

  doctest Pocketeer.Client

  setup do
    server = Bypass.open
    client = build_client(%{site: bypass_server(server)})
    {:ok, server: server, client: client}
  end

  test "get", %{server: server, client: client} do
    bypass server, "POST", "/v3/get", fn conn ->
      json_response(conn, 200, "retrieve_sample.json")
    end

    {:ok, _json} = Pocketeer.Client.get(client)
  end
end
