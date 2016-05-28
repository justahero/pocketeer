defmodule Pocketeer do
  @moduledoc """
  Functions to send requests to the [Pocket API](https://getpocket.com/developer/docs/overview) to
  create, modify or fetch items.
  """

  import Pocketeer.HTTPHandler
  import Pocketeer.TagsHelper

  alias Pocketeer.Client

  @add_options [:url, :tags, :title, :tweet_id]

  @doc """
  Fetches a list of articles / items from the Pocket API.

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

  @doc """
  Fetches a list of articles / items from Pocket with default settings.

  See documentation of `Pocketeer.get/2` for more details.
  """
  @spec get(Client.t | map) :: {:ok, Response.t} | {:error, HTTPError.t}
  def get(%Client{} = client) do get(client, %{}) end

  @doc """
  Fetches a list of articles / items from the Pocket API.

  ## Parameters

    - `client`: The API client with consumer key and access token
    - `options`: The options struct for the Retrieve API endpoint

  Returns the body of the `Pocketeer.Response` or raises an exception with error message.
  """
  @spec get!(Client.t | map, Get.t | map) :: {:ok, Response.t} | {:error, HTTPError.t}
  def get!(%Client{} = client, options \\ %{}) do
    case get(client, options) do
      {:ok, body}      -> body
      {:error, reason} -> raise reason
    end
  end

  @doc """
  Saves / adds a new article in Pocket.

  ## Parameters

  `client` - either a `Pocketeer.Client` struct or a map that contains `consumer_key` and `access_token`.

  `options` - an options map with properties to save

    * `url` - The url to save in Pocket (required)
    * `tags` - A list of tags (optional)
    * `title` - The title of the entry (optional)
    * `tweet_id` - The id of the tweet to link the item with (optional)

  ## Examples

  To store an item with url, title and tags with a `Pocketeer.Client`.

  ```
  client = Pocketeer.Client.new("consumer_key", "access_token")
  Pocketeer.add(client, %{url: "http://example.com", title: "Hello", tags: "news"})
  ```

  For storing an article with reference to a tweet.

  ```
  options = %{url: "http://linkto.me", tweet_id: "5678"}
  Pocketeer.add(%{consumer_key: "abcd", access_token: "1234"}, options)
  ```

  """
  @spec add(Client.t | map, map) :: {:ok, Response.t} | {:error, HTTPError.t}
  def add(%Client{} = client, %{url: _} = options) do
    {options, _} = Dict.split(options, @add_options)
    args = default_args(client, options |> parse_options)
    HTTPotion.post("#{client.site}/v3/add", args)
    |> handle_response
  end
  def add(%{consumer_key: key, access_token: token}, %{url: _} = options) do
    add(Client.new(key, token), options)
  end

  # private methods

  defp parse_options(%{tags: tags} = options) do
    %{options | tags: parse_tags(tags)}
  end
  defp parse_options(%{} = options) do options end

end
