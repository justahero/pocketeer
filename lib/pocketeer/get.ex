defmodule Pocketeer.Get do
  import Pocketeer.HTTPHandler

  alias Pocketeer.HTTPHandler

  def get(client) do
    HTTPotion.post("#{client.site}/v3/get", default_args(client))
    |> handle_response
  end

  def get!(client) do
    response = HTTPotion.post("#{client.site}/v3/get", default_args(client)) |> handle_response
    case response do
      {:ok, body}      -> body
      {:error, reason} -> raise reason
    end
  end

  defp default_options(client) do
    %{
      consumer_key: client.consumer_key,
      access_token: client.access_token
    } |> Poison.encode!
  end

  defp default_args(client) do
    [
      body: default_options(client),
      headers: request_headers
    ]
  end
end
