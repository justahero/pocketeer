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

  test "add with url only", %{server: server, client: client} do
    bypass server, "POST", "/v3/add", fn conn ->
      assert conn.query_string == ""
      assert conn.body_params["access_token"] == "1234"
      assert conn.body_params["consumer_key"] == "abcd"
      assert conn.body_params["url"] == "http://example.com"
      json_response(conn, 200, "add_success.json")
    end

    options = %{url: "http://example.com"}
    {:ok, body} = Add.add(client, options)
    assert Poison.Parser.parse!(body)
  end

  test "add with parameters", %{server: server, client: client} do
    bypass server, "POST", "/v3/add", fn conn ->
      assert conn.query_string == ""
      assert conn.body_params["url"] == "http://example.com"
      assert conn.body_params["tags"] == "foo, bar"
      assert conn.body_params["tweet_id"] == "tweet"
      assert conn.body_params["title"] == "Try it"
      json_response(conn, 200, "add_success.json")
    end

    options = %{url: "http://example.com", title: "Try it", tweet_id: "tweet", tags: ["foo", "bar"]}
    {:ok, body} = Add.add(client, options)
    assert Poison.Parser.parse!(body)
  end

  test "add with some ignored parameters", %{server: server, client: client} do
    bypass server, "POST", "/v3/add", fn conn ->
      assert conn.body_params["url"] == "http://example.com"
      assert Map.has_key?(conn.body_params, "foo") == false
      json_response(conn, 200, "add_success.json")
    end

    options = %{url: "http://example.com", foo: "bar"}
    {:ok, body} = Add.add(client, options)
    assert Poison.Parser.parse!(body)
  end
end
