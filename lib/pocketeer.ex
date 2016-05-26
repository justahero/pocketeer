defmodule Pocketeer do
  import Pocketeer.HTTPHandler

  alias Pocketeer.Client

  @doc """
  Main function to retrieve articles / items from the Pocket API.

  The method allows to either provide a map of options as defined in the official API documentation or by
  building a `Pocketeer.Get` struct, which might be easier to use

  ## Parameters

    - `client`: The `Pocketeer.Client` struct with consumer key and access token
    - `options`: The options struct for the Retrieve API endpoint

  ## Examples

  It is possible to use a map with options, see the [Pocket API documentation](https://getpocket.com/developer/docs/v3/retrieve)

  ```elixir
  # returns a list of the 10 newest favorites in full detail
  client = Pocketeer.Client.new("consumer_key", "access_token")
  {:ok, response} = Pocketeer.get(client, %{sort: :newest, favorite: 1, detailType: :complete, count: 10})
  ```

  For more convenience there is also the `Pocketeer.Get` struct, that accepts a list of arguments,
  filters and transforms data to be compatible with this function.

  ```elixir
  # find the oldest 5 untagged videos from youtube
  options = Pocketeer.Get.new(%{sort: :oldest, count: 5, domain: "youtube.com", tag: :untagged, contentType: :video})
  {:ok, response} = Pocketeer.get(%{consumer_key: "abcd", access_token: "1234", options})
  ```

  """
  @spec get(Client.t | map, Get.t | map) :: {:ok, Response.t} | {:error, HTTPError.t}
  def get(%Client{} = client, %{} = options) do
    HTTPotion.post("#{client.site}/v3/get", default_args(client, options))
    |> handle_response
  end
  def get(%{consumer_key: key, access_token: token}, %{} = options) do
    get(Client.new(key, token), options)
  end
  @spec get(Client.t | map) :: {:ok, Response.t} | {:error, HTTPError.t}
  def get(%Client{} = client) do get(client, %{}) end

  @doc """
  Returns a list of articles / items from the Pocket API.

  ## Parameters

    - `client`: The API client with consumer key and access token
    - `options`: The options struct for the Retrieve API endpoint

  Returns the body of the `Pocketeer.Response` or raises an exception.
  """
  @spec get!(Client.t | map, Get.t | map) :: {:ok, Response.t} | {:error, HTTPError.t}
  def get!(%Client{} = client, options \\ %{}) do
    case get(client, options) do
      {:ok, body}      -> body
      {:error, reason} -> raise reason
    end
  end
end
