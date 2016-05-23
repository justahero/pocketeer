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

  test "add item", %{server: server, client: client} do
    bypass server, "POST", "/v3/send", fn conn ->
      assert_include %{"action" => "add", "url" => "example.com"}, conn.body_params["actions"]
      json_response(conn, 200, "send_favorite_success.json")
    end

    Send.post(Item.add(%{url: "example.com"}), client)
  end

  test "archive item", %{server: server, client: client} do
    bypass server, "POST", "/v3/send", fn conn ->
      assert_include %{"action" => "archive", "item_id" => "1234"}, conn.body_params["actions"]
      json_response(conn, 200, "send_favorite_success.json")
    end

    Send.post(Item.archive("1234"), client)
  end

  test "archive multiple items", %{server: server, client: client} do
    bypass server, "POST", "/v3/send", fn conn ->
      assert_include %{"action" => "archive", "item_id" => "1234"}, conn.body_params["actions"]
      assert_include %{"action" => "archive", "item_id" => "9876"}, conn.body_params["actions"]
      json_response(conn, 200, "send_favorite_success.json")
    end

    Item.new
    |> Item.archive(["1234", "9876"])
    |> Send.post(client)
  end

  test "unarchive multiple items" do
    actual = Item.new
             |> Item.unarchive("1234")
             |> Item.unarchive("9876")

    assert_include %{action: "readd", item_id: "1234"}, actual
    assert_include %{action: "readd", item_id: "9876"}, actual
  end

  test "favorite items" do
    actual = Item.new
             |> Item.favorite(["1234", "2345"])
             |> Item.favorite("9876")

    assert_include %{action: "favorite", item_id: "1234"}, actual
    assert_include %{action: "favorite", item_id: "2345"}, actual
    assert_include %{action: "favorite", item_id: "9876"}, actual
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
