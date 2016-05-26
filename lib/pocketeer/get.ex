defmodule Pocketeer.Get do
  @moduledoc """
  This module implements the Retrieve endpoint of the Pocket API and offers a few flavors
  of access.
  """

  @type state       :: :unread | :archive | :all
  @type favorite    :: true | false
  @type tag         :: binary | :untagged
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
            favorite: nil,
            tag: nil,
            contentType: nil,
            sort: nil,
            detailType: nil,
            search: nil,
            domain: nil,
            since: 0,
            count: 10,
            offset: 0

  @options [:state, :favorite, :tag, :contentType, :sort, :detailType, :search, :domain, :since, :count, :offset]

  @states       [:unread, :achive, :all]
  @contentTypes [:article, :video, :image]
  @sorts        [:newest, :oldest, :title, :site]
  @detailTypes  [:simple, :complete]

  @doc """
  Builds a new Get struct using the `opts` provided. It handles all allowed
  values for the Retrieve API endpoint.

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
  def new(opts) do
    struct(__MODULE__, opts |> filter_options |> parse_options)
  end

  defp filter_options(options) do
    options |> Dict.take(@options)
  end

  defp parse_options(options) do
    options
    |> parse_state
    |> parse_favorite
    |> parse_content_type
    |> parse_sort
    |> parse_detail_type
  end

  defp parse_state(options) do
    case Map.get(options, :state) do
      v when v in @states -> options
      _ -> Map.delete(options, :state)
    end
  end

  defp parse_favorite(options) do
    case Map.get(options, :favorite) do
      true  -> %{options | favorite: 1}
      false -> %{options | favorite: 0}
      _     -> Map.delete(options, :favorite)
    end
  end

  defp parse_content_type(options) do
    case Map.get(options, :contentType) do
      v when v in @contentTypes -> options
      _ -> Map.delete(options, :contentType)
    end
  end

  defp parse_sort(options) do
    case Map.get(options, :sort) do
      v when v in @sorts -> options
      _ -> Map.delete(options, :sort)
    end
  end

  defp parse_detail_type(options) do
    case Map.get(options, :detailType) do
      v when v in @detailTypes -> options
      _ -> Map.delete(options, :detailType)
    end
  end

  defp tags(options) do
    options
  end
end
