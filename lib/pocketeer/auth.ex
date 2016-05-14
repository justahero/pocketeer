defmodule Pocketeer.Auth do
  @request_token_url "https://getpocket.com/v3/oauth/request"
  @authorization_url "https://getpocket.com/v3/oauth/authorize"

  @request_headers [{"Content-Type", "application/json; charset=UTF-8"}, {"X-Accept", "application/json"}]

  alias Pocketeer.Response
  alias Pocketeer.HTTPError

  @doc """
  Returns the URL to authorize the application in the Pocket API

  ## Parameters

    - request_token: The request token to authorize the app with
    - redirect_uri: The URL the user is redirected to after authorization

  Returns the authorization URL with all parameters
  """
  @spec authorize_url(String.t, String.t) :: String.t
  def authorize_url(request_token, redirect_uri) do
    "#{@authorization_url}?request_token=#{request_token}&redirect_uri=#{URI.encode_www_form(redirect_uri)}"
  end

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

  @doc """
  Requests an access token from the Pocket API.

  The method requires the `request_token` fetched from `Pocketeer.Auth.get_request_token`
  method.

  ## Parameters

    - consumer_key: The consumer key used from the Pocket API
    - request_token: The request token to authorize the application

  Returns `HTTP.Response` if request succeeds
  Returns `Pocketeer.HTTPError` if a request fails
  """
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
        {:error, %HTTPError{message: parse_error_message(body, headers)}}
      %HTTPotion.HTTPError{message: message} ->
        {:error, %HTTPError{message: message}}
      _ ->
        {:error, %HTTPError{message: "Unknown error"}}
    end
  end

  defp process_body(response) do
    Poison.Parser.parse!(response.body, keys: :atoms!)
  end

  defp parse_error_message(body, headers) do
    case headers[:'x-error'] do
      nil ->
        body
      error ->
        "#{body}, error"
    end
  end
end
