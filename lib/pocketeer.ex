defmodule Pocketeer do
  import Pocketeer.Get
  import Pocketeer.HTTPError
  import Pocketeer.HTTPHandler

  @doc """
  Main function to retrieve articles / items from the Pocket Retrieve API

  ## Parameters

    - `client`: The API client with consumer key and access token
    - `options`: The options struct for the Retrieve API endpoint

  """
  @spec get(Client.t, Get.t) :: {:ok, Response.t} | {:error, HTTPError.t}
  def get(client, options \\ %{}) do
    HTTPotion.post("#{client.site}/v3/get", default_args(client, options))
    |> handle_response
  end

  def get!(client, options \\ %{}) do
    case get(client, options) do
      {:ok, body}      -> body
      {:error, reason} -> raise reason
    end
  end

  defp build_body(client, options) do
    %{
      consumer_key: client.consumer_key,
      access_token: client.access_token
    }
    |> Map.merge(options)
    |> Poison.encode!
  end

  defp default_args(client, options) do
    [
      body: build_body(client, options),
      headers: request_headers,
      timeout: 10_000
    ]
  end
end
