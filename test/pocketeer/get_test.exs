defmodule Pocketeer.GetTest do
  use ExUnit.Case, async: false

  import Pocketeer.TestHelpers
  alias Pocketeer.Get

  doctest Pocketeer.Get

  setup do
    server = Bypass.open
    client = build_client(%{site: bypass_server(server)})
    {:ok, server: server, client: client}
  end

  test "get with invalid state" do
    options = Get.new(%{state: "foo"})
    assert Map.get(options, :state) == :unread
  end

  test "get without valid favorite property" do
    options = Get.new(%{favorite: "unused"})
    assert Map.get(options, :favorite) == nil
  end

  test "get with valid sort :oldest" do
    options = Get.new(%{sort: :oldest})
    assert Map.get(options, :sort) == :oldest
  end

  test "get with invalid sort" do
    options = Get.new(%{sort: :unknown})
    assert Map.get(options, :sort) == nil
  end

  test "get", %{server: server, client: client} do
    bypass server, "POST", "/v3/get", fn conn ->
      assert conn.query_string == ""
      assert conn.body_params["access_token"] == "1234"
      assert conn.body_params["consumer_key"] == "abcd"
      json_response(conn, 200, "get_sample.json")
    end

    {:ok, body} = Pocketeer.get(client)
    assert Poison.Parser.parse!(body)
  end

  test "get! raises on error", %{server: server, client: client} do
    bypass server, "POST", "/v3/get", fn conn ->
      Plug.Conn.resp(conn, 400, "400 Bad Request")
    end

    assert_raise Pocketeer.HTTPError, fn ->
      Pocketeer.get!(client)
    end
  end

  test "get accepts options", %{server: server, client: client} do
    bypass server, "POST", "/v3/get", fn conn ->
      assert conn.body_params["state"] == "unread"
      assert conn.body_params["tag"] == "test"
      json_response(conn, 200, "get_sample.json")
    end

    options = %{state: :unread, tag: "test"}
    {:ok, body} = Pocketeer.get(client, options)
    assert Poison.Parser.parse!(body)
  end

  test "get favorite read videos", %{server: server, client: client} do
    bypass server, "POST", "/v3/get", fn conn ->
      assert conn.body_params["favorite"] == 1
      assert conn.body_params["state"] == "unread"
      assert conn.body_params["contentType"] == "video"
      json_response(conn, 200, "get_favorites.json")
    end

    options = Get.new(%{favorite: true, state: :unread, contentType: :video})

    {:ok, body} = Pocketeer.get(client, options)
    assert Poison.Parser.parse!(body)
  end
end
