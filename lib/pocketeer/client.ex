defmodule Pocketeer.Client do
  @request_headers [
    {"Content-Type", "application/json; charset=UTF-8"},
    {"X-Accept", "application/json"}
  ]

  alias Pocketeer.Response
  alias Pocketeer.HTTPError

  @type t :: %__MODULE__ {
    consumer_key: String.t,
    access_token: String.t,
    site: String.t
  }

  defstruct consumer_key: nil,
            access_token: nil,
            site: "https://getpocket.com"

  @doc """
  Creates a new Pocketeer client

  ## Parameters

    - consumer_key: The consumer key received from the Pocket application page
    - access_token: The access token retrieved after successful authorization with Pocket

  """
  @spec new(String.t, String.t) :: t
  def new(consumer_key, access_token) do
    %__MODULE__{
      consumer_key: consumer_key,
      access_token: access_token
    }
  end

  def new(options) do
    IO.puts inspect(options)
    %__MODULE__{
      consumer_key: options.consumer_key,
      access_token: options.access_token,
      site: options.site
    }
  end

  def get(client) do
    HTTPotion.post(client.site, [body: default_get_options, headers: @request_headers])
    |> handle_response
  end

  defp default_get_options do
    ""
  end

  defp handle_response(response) do
    case response do
      %HTTPotion.Response{body: body, headers: headers, status_code: status} when status in 200..299 ->
        {:ok, Response.new(status, headers, body) |> process_body}
      %HTTPotion.Response{body: body, headers: headers, status_code: status} ->
        {:error, %HTTPError{message: parse_error_message(body, headers)}}
      %HTTPotion.HTTPError{message: message} ->
        {:error, %HTTPError{message: message}}
      _ ->
        {:error, %HTTPError{message: "Unknown error"}}
    end
  end

  defp process_body(response) do
    Poison.Parser.parse!(response.body)
  end

  defp parse_error_message(body, headers) do
    case headers[:'x-error'] do
      nil   -> body
      error -> "#{body}, #{error}"
    end
  end
end
