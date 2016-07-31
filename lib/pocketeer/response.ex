defmodule Pocketeer.Response do
  @moduledoc """
  A basic HTTP Response with status, headers and body.

  When fetching articles from Pocket, this module also holds a property `articles`
  with a list of parsed items.
  """

  alias Pocketeer.Article

  @type status   :: integer
  @type headers  :: map
  @type body     :: String.t
  @type articles :: [Article.t]

  @type t :: %__MODULE__{
    status:   status,
    headers:  headers,
    body:     body,
    articles: articles
  }

  defstruct status: nil,
            headers: %{},
            body: nil,
            articles: []

  @doc false
  def new(status, headers, body) do
    %__MODULE__{
      status:   status,
      headers:  headers,
      body:     body,
      articles: parse_articles(body)
    }
  end

  def parse_articles(%{"status" => _, "list" => list}) do
    list |> Enum.map(fn {_, article} -> Article.new(article) end)
  end
  def parse_articles(_), do: []
end

defimpl String.Chars, for: Pocketeer.Response do
  def to_string(response) do
    "Response #{response.status} - #{inspect(response.body)}"
  end
end
