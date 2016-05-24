defmodule Pocketeer.SendTest do
  use ExUnit.Case, async: false

  import Pocketeer.TestHelpers
  alias Pocketeer.Item
  alias Pocketeer.Send

  doctest Pocketeer.Send

  setup do
    server = Bypass.open
    client = build_client(%{site: bypass_server(server)})
    {:ok, server: server, client: client}
  end

  test "post with single struct", %{server: server, client: client} do
    bypass server, "POST", "/v3/send", fn conn ->
      assert_include %{"action" => "add", "url" => "example.com"}, conn.body_params["actions"]
      json_response(conn, 200, "send_favorite_success.json")
    end

    Send.post(%{action: "add", url: "example.com"}, client)
  end

  test "post with a list of structs", %{server: server, client: client} do
    bypass server, "POST", "/v3/send", fn conn ->
      assert_include %{"action" => "favorite", "item_id" => "1234"}, conn.body_params["actions"]
      assert_include %{"action" => "favorite", "item_id" => "9876"}, conn.body_params["actions"]
      json_response(conn, 200, "send_favorite_success.json")
    end

    items = Item.favorite(["1234", "9876"])
    Send.post(items, client)
  end

  test "post with single Item", %{server: server, client: client} do
    bypass server, "POST", "/v3/send", fn conn ->
      assert_include %{"action" => "archive", "item_id" => "1234"}, conn.body_params["actions"]
      assert_include %{"action" => "archive", "item_id" => "9876"}, conn.body_params["actions"]
      json_response(conn, 200, "send_favorite_success.json")
    end

    item = Item.new
           |> Item.archive(["1234", "9876"])
    Send.post(item, client)
  end

  test "post with multiple mixed Items", %{server: server, client: client} do
    bypass server, "POST", "/v3/send", fn conn ->
      assert_include %{"action" => "archive", "item_id" => "1234"}, conn.body_params["actions"]
      assert_include %{"action" => "archive", "item_id" => "9876"}, conn.body_params["actions"]
      assert_include %{"action" => "delete", "item_id" => "4444"}, conn.body_params["actions"]
      json_response(conn, 200, "send_favorite_success.json")
    end

    items = Item.new
            |> Item.archive(["1234", "9876"])
            |> Item.delete("4444")
    Send.post(items, client)
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
