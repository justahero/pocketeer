defmodule Pocketeer.Add do
  @moduledoc """
  This module implements the Add endpoint of the Pocket API.
  """

  import Pocketeer.HTTPHandler
  alias Pocketeer.Client

  @options [:url, :tags, :title, :tweet_id]

  @doc """
  Adds / Creates a new item on Pocket

  ## Parameters

  `client`: A `Pocketeer.Client` struct that contains `consumer_key` and `access_token`
  `options`: An options map

    - `url`: The url to save in Pocket (required)
    - `tags`: A list of tags (optional)
    - `title`: The title of the entry (optional)
    - `tweet_id`: The id of the tweet to link the item with (optional)

  ## Examples

  ```
  client = Pocketeer.Client.new("consumer_key", "access_token")
  Pocketeer.Add.add(client, %{url: "http://example.com", title: "Hello", tags: "news"})
  ```

  """
  @spec add(Client.t, map) :: {:ok, Response.t} | {:error, HTTPError.t}
  def add(%Client{} = client, %{url: _} = options) do
    {options, _} = Dict.split(options, @options)
    args = default_args(client, options |> parse_options)
    HTTPotion.post("#{client.site}/v3/add", args)
    |> handle_response
  end

  defp parse_options(%{tags: tags} = options) when is_list(tags) do
    %{options | tags: Enum.join(tags, ", ")}
  end
  defp parse_options(%{tags: tags} = options) when is_binary(tags) do
    %{options | tags: tags}
  end
  defp parse_options(%{tags: tags} = options) when is_atom(tags) do
    %{options | tags: to_string(tags)}
  end
  defp parse_options(%{} = options) do options end
end
