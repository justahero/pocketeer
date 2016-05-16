defmodule Pocketeer.Get do
  import Pocketeer.HTTPHandler

  alias Pocketeer.HTTPHandler

  def get(client) do
    HTTPotion.post("#{client.site}/v3/get", [body: default_options(client), headers: request_headers])
    |> handle_response
  end

  defp default_options(client) do
    %{
      consumer_key: client.consumer_key,
      access_token: client.access_token
    } |> Poison.encode!
  end
end
