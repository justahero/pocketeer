defmodule Pocketeer.HTTPHandler do
  @request_headers [
    {"Content-Type", "application/json; charset=UTF-8"},
    {"X-Accept", "application/json"}
  ]

  def request_headers do
    @request_headers
  end
end
