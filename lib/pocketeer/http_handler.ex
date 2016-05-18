defmodule Pocketeer.HTTPHandler do
  alias Pocketeer.Response
  alias Pocketeer.HTTPError

  @request_headers [
    {"Content-Type", "application/json; charset=UTF-8"},
    {"X-Accept", "application/json"},
    {"User-Agent", "Pocketeer"}
  ]

  def request_headers do
    @request_headers
  end

  @spec handle_response(HTTPotion.Response.t) :: {:ok, Response.t} | {:error, HTTPError}
  def handle_response(response) do
    case response do
      %HTTPotion.Response{body: body, headers: headers, status_code: status} when status in 200..299 ->
        {:ok, Response.new(status, headers, body) |> process_body}
      %HTTPotion.Response{body: body, headers: headers, status_code: _status} ->
        {:error, %HTTPError{message: parse_error_message(body, headers)}}
      %HTTPotion.HTTPError{message: message} ->
        {:error, %HTTPError{message: message}}
      _ ->
        {:error, %HTTPError{message: "Unknown error"}}
    end
  end

  def build_body(client, options) do
    %{
      consumer_key: client.consumer_key,
      access_token: client.access_token,
      time: timestamp
    }
    |> Map.merge(options)
    |> Poison.encode!
  end

  def default_args(client, options) do
    [
      body: build_body(client, options),
      headers: request_headers,
      timeout: 10_000
    ]
  end

  def timestamp do
    :os.system_time(:seconds)
  end

  defp process_body(response) do
    Poison.Parser.parse!(response.body)
  end

  defp parse_error_message(body, headers) do
    case Enum.into(headers.hdrs, %{}) do
      %{"x-error": error, "x-error-code": code} -> "#{body}, #{error} (code: #{code})"
      %{"x-error": error} -> "#{body}, #{error}"
      _ -> body
    end
  end
end
