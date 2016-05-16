defmodule Pocketeer.GetTest do
  use ExUnit.Case, async: false

  import Pocketeer.TestHelpers

  doctest Pocketeer.Get

  setup do
    server = Bypass.open
    client = build_client(%{site: bypass_server(server)})
    {:ok, server: server, client: client}
  end

  test "get", %{server: server, client: client} do
    bypass server, "POST", "/v3/get", fn conn ->
      json_response(conn, 200, "retrieve_sample.json")
    end

    {:ok, body} = Pocketeer.Get.get(client)
    assert Poison.Parser.parse!(body)
  end
end
