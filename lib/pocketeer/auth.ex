defmodule Pocketeer.Auth do
  @request_token_url "https://getpocket.com/v3/oauth/request"
  @authorization_url "https://getpocket.com/v3/uauth/authorize"

  @request_headers [{"Content-Type", "application/json; charset=UTF-8"}, {"X-Accept", "application/json"}]

  alias Pocketeer.Response
  alias Pocketeer.HTTPError

  @doc """
  Sends a GET request to fetch a request token

  ## Parameters:

    - consumer_key: The consumer key used from the Pocket API
    - redirect_uri: URL to redirect when the authorization process has been completed

  Returns `HTTP.Response` if request succeeds
  Returns `Pocketeer.HTTPError` if a request fails
  """
  @spec get_request_token(String.t, String.t) :: {:ok, map} | {:error, HTTPError.t}
  def get_request_token(consumer_key, redirect_uri) do
    body = ~s({"consumer_key": "#{consumer_key}", "redirect_uri": "#{redirect_uri}"})
    HTTPotion.post(@request_token_url, [body: body, headers: @request_headers])
    |> handle_response
  end

  @spec get_access_token(String.t, String.t) :: {:ok, map} | {:error, HTTPError.t}
  def get_access_token(consumer_key, request_token) do
    body = ~s({"consumer_key": "#{consumer_key}", "request_token": "#{request_token}"})
    HTTPotion.post(@authorization_url, [body: body, headers: @request_headers])
    |> handle_response
  end

  defp handle_response(response) do
    case response do
      %HTTPotion.Response{body: body, headers: headers, status_code: status} when status in 200..299 ->
        {:ok, Response.new(status, headers, body) |> process_body}
      %HTTPotion.Response{body: body, headers: headers, status_code: status} ->
        {:error, %HTTPError{message: body}}
      %HTTPotion.HTTPError{message: message} ->
        {:error, %HTTPError{message: message}}
      _ ->
        {:error, %HTTPError{message: "Unknown error"}}
    end
  end

  defp process_body(response) do
    Poison.Parser.parse!(response.body, keys: :atoms!)
  end
end
