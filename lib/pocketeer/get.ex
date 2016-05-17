defmodule Pocketeer.Get do
  @moduledoc """
  This module implements the Retrieve endpoint of the Pocket API and offers a few flavors
  of access.
  """

  import Pocketeer.HTTPHandler

  @type state       :: :unread | :archive | :all
  @type favorite    :: 0 | 1
  @type tag         :: :String.t | :untagged
  @type contentType :: :article | :video | :image
  @type sort        :: :newest | :oldest | :title | :site
  @type detailType  :: :simple | :complete
  @type search      :: binary
  @type domain      :: binary
  @type since       :: number
  @type count       :: number
  @type offset      :: number

  @type t :: %__MODULE__{
    state:       state,
    favorite:    favorite,
    tag:         tag,
    contentType: contentType,
    sort:        sort,
    detailType:  detailType,
    search:      search,
    domain:      domain,
    since:       since,
    count:       count,
    offset:      offset
  }

  defstruct state: :unread,
            favorite: :all,
            tag: :all,
            contentType: :all,
            sort: :newest,
            detailType: :simple,
            search: nil,
            domain: nil,
            since: 0,
            count: 10,
            offset: 0

  @doc """
  Main function to retrieve articles / items from the Pocket Retrieve API

  ## Parameters

    - `state`: The state of the article / item, :unread, :archive or :all
    - `favorite`: When given either 0 (un-favorited) or 1 (favorited), if not given all
    - `tag`: A tag name, only returns items with given tag or `_untagged_` to fetch all items without any tags
    - `contentType`: Fetches items of a specific content type, either `:article`, `:video` or `:image` only
    - `sort`: Sorting method, how items are returned, `:newest`, `:oldest`, `:title`, `:site`
    - `detailType`: Returns either less properties when `simple` or all when `complete`
    - `search`: Search term to return only items that match url or title
    - `domain`: Only return items for a specific domain
    - `since`: Unix timestamp to consider that were modified after
    - `count`: The number of items to return (max 10).
    - `offset`: Used with count only, start items from offset position of results.

  """
  @spec get(Client.t, Map.t) :: {:ok, Response.t} | {:error, HTTPError.t}
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

  def favorited(options \\ %{}) do
    Map.put(options, :favorite, 1)
  end

  def unfavorited(options \\ %{}) do
    Map.put(options, :favorite, 0)
  end

  def read(options \\ %{}) do
    Map.put(options, :state, :read)
  end

  def unread(options \\ %{}) do
    Map.put(options, :state, :unread)
  end

  def articles(options \\ %{}) do
    Map.put(options, :contentType, :articles)
  end

  def videos(options \\ %{}) do
    Map.put(options, :contentType, :video)
  end

  def images(options \\ %{}) do
    Map.put(options, :contentType, :image)
  end

  def find(client, search, options \\ %{}) do
    options = Map.put(options, :search, search)
    get(client, options)
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
