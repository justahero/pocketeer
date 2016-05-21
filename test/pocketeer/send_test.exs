defmodule Pocketeer.SendTest do
  use ExUnit.Case, async: false

  import Pocketeer.TestHelpers
  alias Pocketeer.Send

  doctest Pocketeer.Send

  setup do
    server = Bypass.open
    client = build_client(%{site: bypass_server(server)})
    {:ok, server: server, client: client}
  end

  test "archive item", %{server: server, client: client} do
    bypass server, "POST", "/v3/send", fn conn ->
      assert conn.query_string == ""
      assert conn.body_params["access_token"] == "1234"
      assert conn.body_params["consumer_key"] == "abcd"
      assert_include %{"action" => "archive", "item_id" => "1234"}, conn.body_params["actions"]
      json_response(conn, 200, "send_favorite_success.json")
    end

    Send.post(Send.archive("1234"), client)
  end

  test "archive multiple items", %{server: server, client: client} do
    bypass server, "POST", "/v3/send", fn conn ->
      assert_include %{"action" => "archive", "item_id" => "1234"}, conn.body_params["actions"]
      assert_include %{"action" => "archive", "item_id" => "9876"}, conn.body_params["actions"]
      json_response(conn, 200, "send_favorite_success.json")
    end

    Send.new
    |> Send.archive(["1234", "9876"])
    |> Send.post(client)
  end

  test "unarchive item", %{server: server, client: client} do
    bypass server, "POST", "/v3/send", fn conn ->
      assert_include %{"action" => "readd", "item_id" => "1234"}, conn.body_params["actions"]
      assert_include %{"action" => "readd", "item_id" => "9876"}, conn.body_params["actions"]
      json_response(conn, 200, "send_favorite_success.json")
    end

    Send.new
    |> Send.unarchive("1234")
    |> Send.unarchive("9876")
    |> Send.post(client)
  end

  def assert_include(expected, actual) when is_list(actual) do
    result = Enum.any? actual, fn item ->
      Map.drop(item, ["timestamp"]) |> Map.equal?(expected)
    end
    assert result == true
  end
end
