defmodule Pocketeer do
  import Pocketeer.HTTPHandler

  alias Pocketeer.Client

  @doc """
  Main function to retrieve articles / items from the Pocket Retrieve API

  ## Parameters

    - `client`: The API client with consumer key and access token
    - `options`: The options struct for the Retrieve API endpoint

  TODO describe all options
  """
  @spec get(Client.t, Get.t) :: {:ok, Response.t} | {:error, HTTPError.t}
  def get(%Client{} = client, options \\ %{}) do
    HTTPotion.post("#{client.site}/v3/get", default_args(client, options))
    |> handle_response
  end

  @doc """
  Main function to retrieve articles / items from the Pocket Retrieve API

  ## Parameters

    - `client`: The API client with consumer key and access token
    - `options`: The options struct for the Retrieve API endpoint

  TODO describe all options
  """
  @spec get!(Client.t, Get.t) :: {:ok, Response.t} | {:error, HTTPError.t}
  def get!(%Client{} = client, options \\ %{}) do
    case get(client, options) do
      {:ok, body}      -> body
      {:error, reason} -> raise reason
    end
  end
end
