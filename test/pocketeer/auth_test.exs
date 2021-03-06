defmodule Pocketeer.AuthTest do
  use ExUnit.Case, async: false

  import Pocketeer.TestHelpers

  doctest Pocketeer.Auth

  setup do
    server = Bypass.open
    Application.delete_env(:pocketeer, :pocket_url)
    {:ok, server: server}
  end

  test "returns full authorization url" do
    uri = URI.parse(Pocketeer.Auth.authorize_url("abcd", "localhost"))
    assert uri.port == 443
    assert uri.path == "/auth/authorize"

    query = URI.decode_query(uri.query)
    assert query["request_token"] == "abcd"
    assert query["redirect_uri"] == "localhost"
  end

  test "returns OK response with code", %{server: server} do
    Application.put_env(:pocketeer, :pocket_url, bypass_server(server))
    bypass server, "POST", "/v3/oauth/request", fn conn ->
      Plug.Conn.resp(conn, 200, ~s({"code": "123456", "status": null}))
    end

    {:ok, body} = Pocketeer.Auth.get_request_token("123", "localhost")
    assert body == %{"code" => "123456", "status" => nil}
  end

  test "returns message if error occurs", %{server: server} do
    Application.put_env(:pocketeer, :pocket_url, bypass_server(server))
    bypass server, "POST", "/v3/oauth/request", fn conn ->
      Plug.Conn.resp(conn, 400, "400 Bad Request")
    end

    {:error, error} = Pocketeer.Auth.get_request_token("123", "localhost")
    assert error.message == "400 Bad Request"
  end

  test "returns detailed error from HTTP header", %{server: server} do
    headers = [{"x-error", "99"}]
    Application.put_env(:pocketeer, :pocket_url, bypass_server(server))
    bypass server, "POST", "/v3/oauth/request", fn conn ->
      Plug.Conn.resp(%{conn | resp_headers: headers}, 400, "400 Bad Request")
    end

    {:error, error} = Pocketeer.Auth.get_request_token("123", "localhost")
    assert error.message == "400 Bad Request, 99"
  end

  test "returns OK response when access token granted", %{server: server} do
    doc = ~s({"access_token":"token", "username":"pocket"})
    Application.put_env(:pocketeer, :pocket_url, bypass_server(server))
    bypass server, "POST", "/v3/oauth/authorize", fn conn ->
      Plug.Conn.resp(conn, 200, doc)
    end

    {:ok, body} = Pocketeer.Auth.get_access_token("123", "abcd")
    assert body == %{"access_token" => "token", "username" => "pocket"}
  end

  test "returns error response when access token denied", %{server: server} do
    doc = "User rejected code."
    Application.put_env(:pocketeer, :pocket_url, bypass_server(server))
    bypass server, "POST", "/v3/oauth/authorize", fn conn ->
      Plug.Conn.resp(conn, 403, doc)
    end

    {:error, error} = Pocketeer.Auth.get_access_token("123", "abcd")
    assert error.message == doc
  end
end
