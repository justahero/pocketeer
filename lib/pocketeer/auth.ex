defmodule Pocketeer.Auth do
  @request_token_url "https://getpocket.com/v3/oauth/request"
  @authorization_url "https://getpocket.com/v3/uauth/authorize"

  @request_headers [{"Content-Type", "application/json; charset=UTF-8"}, {"X-Accept", "application/json"}]

  alias Pocketeer.Response
  alias Pocketeer.HTTPError

  @doc """
  Sends a GET request to fetch a request token

  ## Parameters:

    - consumer_key: The consumer key given by Pocket

  ## Examples:

      # iex> consumer_key = Application.get_env(:pocketeer, :consumer_key, "123")
      # iex> Pocketeer.Auth.get_request_token(consumer_key, "localhost")
      # {:ok, {}}

  Raises `Pocketeer.HTTPError` if request fails
  """
  @spec get_request_token(String.t, String.t) :: {:ok, Response.t} | {:error, HTTPError.t}
  def get_request_token(consumer_key, redirect_uri) do
    body = ~s({"consumer_key": "#{consumer_key}", "redirect_uri": "#{redirect_uri}"})
    HTTPotion.post(@request_token_url, [body: body, headers: @request_headers])
    |> handle_response
  end

  defp handle_response(response) do
    case response do
      %HTTPotion.Response{body: body, headers: headers, status_code: status} when status in 200..299 ->
        {:ok, Response.new(status, headers, body |> process_body)}
      %HTTPotion.Response{body: body, headers: headers, status_code: status} ->
        {:error, %HTTPError{message: body}}
      %HTTPotion.HTTPError{message: message} ->
        {:error, %HTTPError{message: message}}
      _ ->
        {:error, %HTTPError{message: "Unknown error"}}
    end
  end

  defp process_body(body) do
    body |> Poison.Parser.parse!
  end
end
