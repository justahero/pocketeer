defmodule Pocketeer.AddTest do
  use ExUnit.Case, async: false

  import Pocketeer.TestHelpers
  alias Pocketeer.Add

  doctest Pocketeer.Add

  setup do
    server = Bypass.open
    client = build_client(%{site: bypass_server(server)})
    {:ok, server: server, client: client}
  end

  test "creates options via Add" do
    options = Add.url("http://example.com") |> Add.tags(["foo", "bar"])
    assert options == %{url: "http://example.com", tags: ["foo", "bar"]}
  end

  test "add with url only", %{server: server, client: client} do
    bypass server, "POST", "/v3/add", fn conn ->
      assert conn.query_string == ""
      assert conn.body_params["access_token"] == "1234"
      assert conn.body_params["consumer_key"] == "abcd"
      assert conn.body_params["url"] == URI.encode_www_form("http://localhost/me")
      assert Enum.count(conn.body_params) == 4
      json_response(conn, 200, "add_success.json")
    end

    options = %{url: "http://localhost/me"}
    {:ok, body} = Pocketeer.Add.add(client, options)
    assert Poison.Parser.parse!(body)
  end

  test "add with struct", %{server: server, client: client} do
    bypass server, "POST", "/v3/add", fn conn ->
      assert conn.query_string == ""
      assert conn.body_params["url"] == URI.encode_www_form("http://example.com")
      # assert conn.body_params["tags"] == "foo, bar"
      # assert conn.body_params["tweet_id"] == "tweet"
      # assert conn.body_params["title"] == "Try it"
      json_response(conn, 200, "add_success.json")
    end

    options = Add.url("http://example.com")
    {:ok, body} = Pocketeer.Add.add(client, options)
  end
end
