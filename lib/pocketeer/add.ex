defmodule Pocketeer.Add do
  @moduledoc """
  This module implements the Add endpoint of the Pocket API.
  """

  import Pocketeer.HTTPHandler
  alias Pocketeer.Add

  @type url      :: binary
  @type title    :: String.t
  @type tags     :: String.t | list
  @type tweet_id :: String.t

  @type t :: %__MODULE__{
    url:      url,
    title:    title,
    tags:     tags,
    tweet_id: tweet_id
  }

  defstruct url: "",
            title: "",
            tags: [],
            tweet_id: nil

  @spec new(Keyword.t) :: t
  def new(%{url: _} = options) do
    struct(__MODULE__, options)
  end

  def add(client, %Add{url: _} = options) do
    add(client, Add.new(options))
  end

  def url(options \\ %{}, uri) do
    Map.put(options, :url, uri)
  end

  @spec tags(map, list) :: map
  def tags(options \\ %{}, tags \\ []) do
    Map.put(options, :tags, tags)
  end

  @spec add(Client.t, Add.t) :: {:ok, Response.t} | {:error, HTTPError.t}
  def add(client, %{url: _} = options) do
    options = %{options | url: URI.encode_www_form(options[:url])}
    HTTPotion.post("#{client.site}/v3/add", default_args(client, options))
    |> handle_response
  end
end
