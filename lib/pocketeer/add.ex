defmodule Pocketeer.Add do
  @moduledoc """
  Send requests to the [Add endpoint](https://getpocket.com/developer/docs/v3/add) of the Pocket API.
  """

  import Pocketeer.HTTPHandler
  import Pocketeer.TagsHelper
  alias Pocketeer.Client

  @options [:url, :tags, :title, :tweet_id]

  @doc """
  Saves a new article on Pocket.

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
  Pocketeer.Add.add(client, %{url: "http://example.com", title: "Hello", tags: "news"})
  ```

  For storing an article with reference to a tweet.

  ```
  options = %{url: "http://linkto.me", tweet_id: "5678"}
  Pocketeer.Add.add(%{consumer_key: "abcd", access_token: "1234"}, options)
  ```

  """
  @spec add(Client.t | map, map) :: {:ok, Response.t} | {:error, HTTPError.t}
  def add(%Client{} = client, %{url: _} = options) do
    {options, _} = Dict.split(options, @options)
    args = default_args(client, options |> parse_options)
    HTTPotion.post("#{client.site}/v3/add", args)
    |> handle_response
  end
  def add(%{consumer_key: key, access_token: token}, %{url: _} = options) do
    add(Client.new(key, token), options)
  end

  defp parse_options(%{tags: tags} = options) do
    %{options | tags: parse_tags(tags)}
  end
  defp parse_options(%{} = options) do options end
end
