defmodule Pocketeer.AuthTest do
  use ExUnit.Case, async: false
  doctest Pocketeer.Auth

  import Mock

  test "returns OK response" do
    doc = ~s({"code": "123456", "status": null})
    with_mock HTTPotion,
      [post: fn(_url), _headers ->
        %HTTPotion.Response{status_code: 200, body: doc, headers: []} end] do

      Pocketeer.Auth.get_request_token("123", "localhost")
      assert called HTTPotion.post("https://getpocket.com/v3/oauth/request", :_)
    end
  end

  test "returns 400 Bad Request if consumer key not valid" do
    body = "400 Bad Request"
    with_mock HTTPotion,
      [post: fn(_url), _headers ->
        %HTTPotion.Response{status_code: 200, body: body, headers: []} end] do

      Pocketeer.Auth.get_request_token("123", "localhost")
      assert called HTTPotion.post("https://getpocket.com/v3/oauth/request", :_)
    end
  end
end
