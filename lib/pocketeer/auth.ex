defmodule Pocketeer.Auth do
  import Pocketeer.HTTPHandler

  @doc """
  Returns the URL to authorize the application in the Pocket API

  ## Parameters

    - request_token: The request token to authorize the app with
    - redirect_uri: The URL the user is redirected to after authorization

  Returns the authorization URL with all parameters
  """
  @spec authorize_url(String.t, String.t) :: String.t
  def authorize_url(request_token, redirect_uri) do
    "#{authorize_url}?request_token=#{request_token}&redirect_uri=#{URI.encode_www_form(redirect_uri)}"
  end

  @doc """
  Sends a request to fetch a request token

  ## Parameters:

    - consumer_key: The consumer key used from the Pocket API
    - redirect_uri: URL to redirect when the authorization process has been completed

  Returns `HTTP.Response` if request succeeds
  Returns `Pocketeer.HTTPError` if a request fails
  """
  @spec get_request_token(String.t, String.t) :: {:ok, map} | {:error, HTTPError.t}
  def get_request_token(consumer_key, redirect_uri) do
    body = ~s({"consumer_key": "#{consumer_key}", "redirect_uri": "#{redirect_uri}"})
    HTTPotion.post(request_token_url, [body: body, headers: request_headers])
    |> handle_response
  end
  @spec get_request_token(map) :: {:ok, map} | {:error, HTTPError.t}
  def get_request_token(%{consumer_key: key, redirect_uri: uri}) do
    get_request_token(key, uri)
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
    body = ~s({"consumer_key": "#{consumer_key}", "code": "#{request_token}"})
    HTTPotion.post(access_token_url, [body: body, headers: request_headers])
    |> handle_response
  end
  def get_access_token(%{consumer_key: key, request_token: token}) do
    get_access_token(key, token)
  end

  defp authorize_url do
    "#{pocket_url}/auth/authorize"
  end

  defp access_token_url do
    "#{pocket_url}/v3/oauth/authorize"
  end

  defp request_token_url do
    "#{pocket_url}/v3/oauth/request"
  end

  defp pocket_url do
    Application.get_env(:pocketeer, :pocket_url, "https://getpocket.com")
  end
end
