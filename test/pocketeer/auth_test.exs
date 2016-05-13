defmodule Pocketeer.AuthTest do
  use ExUnit.Case, async: false
  doctest Pocketeer.Auth

  import Mock

  test "returns error if consumer key not given" do
    assert {:ok, _} = Pocketeer.Auth.get_request_token("123", "localhost")
  end

  test "returns OK response" do
    doc = ~s({"code": "123456"})
    with_mock HTTPotion,
      [post: fn(_url), _headers ->
         %HTTPotion.Response{status_code: 200, body: doc, headers: []} end] do

      Pocketeer.Auth.get_request_token("123", "localhost")
      assert called HTTPotion.post("https://getpocket.com/v3/oauth/request", :_)
    end
  end
end
