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

  @doc """
  Builds a new Struct with `url` and `tags`.
  """
  @spec new(map) :: t
  def new(%{url: _, tags: _} = options) do
    options = %{options | url: URI.encode_www_form(options[:url])}
    options = %{options | tags: Enum.join(options[:tags], ", ")}
    struct(__MODULE__, options)
  end
  def new(%{url: _} = options) do
    options = %{options | url: URI.encode_www_form(options[:url])}
    struct(__MODULE__, options)
  end

  @spec add(Client.t, Add.t) :: {:ok, Response.t} | {:error, HTTPError.t}
  def add(client, options = %Add{url: _}) do
    HTTPotion.post("#{client.site}/v3/add", default_args(client, options))
    |> handle_response
  end

  @spec add(Client.t, map) :: {:ok, Response.t} | {:error, HTTPError.t}
  def add(client, options = %{url: _}) do
    add(client, Add.new(options))
  end
end
