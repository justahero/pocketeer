defmodule Pocketeer.Get do
  @moduledoc """
  Builds structs for use with [Retrieve endpoint](https://getpocket.com/developer/docs/v3/retrieve) of the Pocket API.
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

  @typedoc """
  A map of properties that can be used with `Pocketeer.get/2`.
  """
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

  Builds a parameters strucht to get items from the [Pocket API](https://getpocket.com/developer/docs/v3/retrieve).
  This struct accepts a list of options that define how items are fetched. The struct can be given as parameter to `Pocketeer.get`.

  *`:state`* - the state of the articles.

    * `:unread` - only return unread articles (default)
    * `:archive` - only return archived articles
    * `:all` - return both unread and archived articles

  `:favorite` - when not given returns all

    * `true` - return favorited articles only
    * `false` - return non-favorited articles only

  `:tag` - a tag to return items

    * `tag_name` - only returns articles with the tag
    * `untagged` - return articles that have no tag at all

  `:contentType` - the content type of the articles

    * `:article` - only return articles
    * `:video` -  only return videos or articles with embedded videos
    * `:image` - only return images

  `:sort` - sorting method in which returned articles are ordered

    * `:newest` - orders items from recent to oldest
    * `:oldest` - orders items from oldest to recent
    * `:title` - orders items by title in alphabetical order
    * `:site` - orders items by url in alphabetical order

  `:detailType` - defines detail of result

    * `:simple` - only return titles and urls of items
    * `:complete` - return full data for each item

  `:search` - when given return only items that where the title or url matches the string

  `:domain` - when given only return items from a particular domain

  `:since` - when given returns items that were modified after the given unix timestamp

  `:count` - when given sets the number of items to return

  `:offset` - when given defines the offset position of results, works only in combination with `:count`

  """
  @spec new(map) :: t
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
end
