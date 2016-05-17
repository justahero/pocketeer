defmodule Pocketeer.Get do
  @moduledoc """
  This module implements the Retrieve endpoint of the Pocket API and offers a few flavors
  of access.
  """

  import Pocketeer.HTTPHandler
  alias Pocketeer.HTTPHandler

  @type state       :: :unread | :archive | :all
  @type favorite    :: :unfavored | :favored
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

  @spec get(Client.t, Map.t) :: {:ok, Response.t} | {:error, HTTPError.t}
  def get(client, options \\ %{}) do
    HTTPotion.post("#{client.site}/v3/get", default_args(client, options))
    |> handle_response
  end

  def get_favorites(client, options \\ %{}) do
    options = Map.put(options, :favorite, :favored)
    get(client, options)
  end

  def get_unread(client, options \\ %{}) do
    options = Map.put(options, :state, :unread)
    get(client, options)
  end

  def find(client, search, options \\ %{}) do
    options = Map.put(options, :search, search)
    get(client, options)
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
