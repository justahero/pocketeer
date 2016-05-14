defmodule Pocketeer.AuthTest do
  use ExUnit.Case, async: false
  doctest Pocketeer.Auth

  import Mock

  test "returns OK response with code" do
    doc = ~s({"code": "123456", "status": null})
    with_mock HTTPotion,
      [post: fn(_url), _headers ->
        %HTTPotion.Response{status_code: 200, body: doc, headers: []} end] do

      {:ok, body} = Pocketeer.Auth.get_request_token("123", "localhost")
      assert body == %{code: "123456", status: nil}
      assert called HTTPotion.post("https://getpocket.com/v3/oauth/request", :_)
    end
  end

  test "returns 400 Bad Request if consumer key not valid" do
    body = "400 Bad Request"
    with_mock HTTPotion,
      [post: fn(_url), _headers ->
        %HTTPotion.Response{status_code: 400, body: body, headers: []} end] do

      {:error, error} = Pocketeer.Auth.get_request_token("123", "localhost")
      assert error.message == body
      assert called HTTPotion.post("https://getpocket.com/v3/oauth/request", :_)
    end
  end

  test "returns error message on HTTPError" do
    with_mock HTTPotion,
      [post: fn(_url), _headers ->
        %HTTPotion.HTTPError{message: "econnrefused"} end] do

      {:error, error} = Pocketeer.Auth.get_request_token("123", "invalid url")
      assert error.message == "econnrefused"
      assert called HTTPotion.post("https://getpocket.com/v3/oauth/request", :_)
    end
  end

  test "returns OK response with access token" do
    doc = ~s({"access_token":"token", "username":"pocket"})
    with_mock HTTPotion,
      [post: fn(_url), _headers ->
        %HTTPotion.Response{status_code: 200, body: doc, headers: []} end] do
      {:ok, body} = Pocketeer.Auth.get_access_token("123", "abcd")

      assert body == %{access_token: "token", username: "pocket"}
      assert called HTTPotion.post("https://getpocket.com/v3/oauth/authorize", :_)
    end
  end
end
