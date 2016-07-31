defmodule PocketeerTest do
  use ExUnit.Case, async: false

  import Pocketeer.TestHelpers

  alias Pocketeer.Client
  alias Pocketeer.Get
  alias Pocketeer.Item

  doctest Pocketeer

  setup do
    server = Bypass.open

    Application.put_env(:pocketeer, :pocket_url, bypass_server(server))

    client = Client.new(%{consumer_key: "abcd", access_token: "1234"})
    {:ok, server: server, client: client}
  end

  test "get", %{server: server, client: client} do
    bypass server, "POST", "/v3/get", fn conn ->
      assert conn.query_string == ""
      assert conn.body_params["access_token"] == "1234"
      assert conn.body_params["consumer_key"] == "abcd"
      json_response(conn, 200, "get_sample.json")
    end

    {:ok, response} = Pocketeer.get(client)
    assert is_map(response)
  end

  test "get! returns response body", %{server: server, client: client} do
    bypass server, "POST", "/v3/get", fn conn ->
      json_response(conn, 200, "get_sample.json")
    end

    options = %{state: :unread, tag: "test"}
    response = Pocketeer.get!(client, options)
    assert is_map(response)
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
    {:ok, response} = Pocketeer.get(client, options)
    assert is_map(response)
  end

  test "get favorite read videos", %{server: server, client: client} do
    bypass server, "POST", "/v3/get", fn conn ->
      assert conn.body_params["favorite"] == 1
      assert conn.body_params["state"] == "unread"
      assert conn.body_params["contentType"] == "video"
      json_response(conn, 200, "get_favorites.json")
    end

    options = Get.new(%{favorite: true, state: :unread, contentType: :video})

    {:ok, response} = Pocketeer.get(client, options)

    assert Enum.count(response.articles) == 1
    assert is_map(response)
  end

  test "get parses articles into response", %{server: server, client: client} do
    bypass server, "POST", "/v3/get", fn conn ->
      json_response(conn, 200, "get_sample.json")
    end

    {:ok, response} = Pocketeer.get(client, %{})

    assert Enum.count(response.articles) == 1

    [article | _] = response.articles
    assert Enum.count(article.images) == 1
    assert Enum.count(article.videos) == 1
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
    {:ok, _body} = Pocketeer.add(client, options)
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
    {:ok, _body} = Pocketeer.add(client, options)
  end

  test "add with some ignored parameters", %{server: server, client: client} do
    bypass server, "POST", "/v3/add", fn conn ->
      assert conn.body_params["url"] == "http://example.com"
      assert Map.has_key?(conn.body_params, "foo") == false
      json_response(conn, 200, "add_success.json")
    end

    options = %{url: "http://example.com", foo: "bar"}
    {:ok, _body} = Pocketeer.add(client, options)
  end

  test "post with single struct", %{server: server, client: client} do
    bypass server, "POST", "/v3/send", fn conn ->
      assert_include %{"action" => "add", "url" => "example.com"}, conn.body_params["actions"]
      json_response(conn, 200, "send_favorite_success.json")
    end

    Pocketeer.post(%{action: "add", url: "example.com"}, client)
  end

  test "post with a list of structs", %{server: server, client: client} do
    bypass server, "POST", "/v3/send", fn conn ->
      assert_include %{"action" => "favorite", "item_id" => "1234"}, conn.body_params["actions"]
      assert_include %{"action" => "favorite", "item_id" => "9876"}, conn.body_params["actions"]
      json_response(conn, 200, "send_favorite_success.json")
    end

    items = Item.favorite(["1234", "9876"])
    Pocketeer.post(items, client)
  end

  test "post with single Item", %{server: server, client: client} do
    bypass server, "POST", "/v3/send", fn conn ->
      assert_include %{"action" => "archive", "item_id" => "1234"}, conn.body_params["actions"]
      assert_include %{"action" => "archive", "item_id" => "9876"}, conn.body_params["actions"]
      json_response(conn, 200, "send_favorite_success.json")
    end

    Item.new
    |> Item.archive(["1234", "9876"])
    |> Pocketeer.post(client)
  end

  test "post with multiple mixed Items", %{server: server, client: client} do
    bypass server, "POST", "/v3/send", fn conn ->
      assert_include %{"action" => "archive", "item_id" => "1234"}, conn.body_params["actions"]
      assert_include %{"action" => "archive", "item_id" => "9876"}, conn.body_params["actions"]
      assert_include %{"action" => "delete", "item_id" => "4444"}, conn.body_params["actions"]
      json_response(conn, 200, "send_favorite_success.json")
    end

    Item.new
    |> Item.archive(["1234", "9876"])
    |> Item.delete("4444")
    |> Pocketeer.post(client)
  end

  defp assert_include(expected, actual) when is_list(actual) do
    actual = List.flatten(actual)
    result = Enum.any? actual, fn item ->
      Map.drop(item, ["timestamp"]) |> Map.equal?(expected)
    end
    assert result == true
  end

  defp assert_include(expected, %Item{} = item) do
    assert_include(expected, item.actions)
  end
end
