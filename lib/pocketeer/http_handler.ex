defmodule Pocketeer.HTTPHandler do
  alias Pocketeer.Response
  alias Pocketeer.HTTPError

  @request_headers [
    {"Content-Type", "application/json; charset=UTF-8"},
    {"X-Accept", "application/json"}
  ]

  def request_headers do
    @request_headers
  end

  def handle_response(response) do
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
