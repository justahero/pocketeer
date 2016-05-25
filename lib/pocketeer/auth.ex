defmodule Pocketeer.Auth do
  @moduledoc """
  Authorization module to fetch `request_token` and `access_token` from the Pocket API
  necessary to retrieve, modify or access items.
  """

  import Pocketeer.HTTPHandler
  alias Pocketeer.Response

  @doc """
  Returns authorization URL for Pocket to authorize the application.

  ## Examples

      iex> Pocketeer.Auth.authorize_url("abcd", "http://example")
      "https://getpocket.com/auth/authorize?request_token=abcd&redirect_uri=http%3A%2F%2Fexample.com"

  ## Parameters

    - `request_token`: The request token to authorize the app with
    - `redirect_uri`: The URL the user is redirected to after authorization

  Returns the authorization URL with all parameters
  """
  @spec authorize_url(String.t, String.t) :: String.t
  def authorize_url(request_token, redirect_uri) do
    "#{authorize_url}?request_token=#{request_token}&redirect_uri=#{URI.encode_www_form(redirect_uri)}"
  end

  @doc """
  Returns authorization URL for Pocket to authorize the application.

  ## Examples

      iex> Pocketeer.Auth.authorize_url(%{request_token: "abcd", redirect_uri: "http://example.com"})
      "https://getpocket.com/auth/authorize?request_token=abcd&redirect_uri=http%3A%2F%2Fexample.com"

  ## Parameters

    - A struct with `request_token` and `redirect_uri` present.

  """
  @spec authorize_url(map) :: String.t
  def authorize_url(%{request_token: token, redirect_uri: uri}) do
    authorize_url(token, uri)
  end

  @doc """
  Sends a request to fetch a `request_token` from Pocket.

  ## Examples

  ```
  Pocketeer.Auth.get_request_token("1234", "http://example.com")
  ```

  ## Parameters:

    - `consumer_key`: The consumer key used from the Pocket API
    - `redirect_uri`: URL to redirect when the authorization process has been completed

  """
  @spec get_request_token(String.t, String.t) :: {:ok, Response.t} | {:error, HTTPError.t}
  def get_request_token(consumer_key, redirect_uri) do
    body = ~s({"consumer_key": "#{consumer_key}", "redirect_uri": "#{redirect_uri}"})
    HTTPotion.post(request_token_url, [body: body, headers: request_headers])
    |> handle_response
  end

  @doc """
  Sends a request to fetch a `request_token` from Pocket.
  
  ## Examples

  ```
  options = %{consumer_key: "1234", redirect_uri: "http://example.com"}
  Pocketeer.Auth.get_request_token(options)
  ```

  """
  @spec get_request_token(map) :: {:ok, Response.t} | {:error, HTTPError.t}
  def get_request_token(%{consumer_key: key, redirect_uri: uri}) do
    get_request_token(key, uri)
  end

  @doc """
  Requests an access token from the Pocket API.

  The method requires a `request_token` fetched from `Pocketeer.Auth.get_request_token`
  method.

  ## Examples

  ```
  Pocketeer.Auth.get_access_token("abcd", "1234")
  {:ok, Response{}}
  ```

  ## Parameters

    - `consumer_key`: The consumer key used from the Pocket API
    - `request_token`: The request token to authorize the application

  """
  @spec get_access_token(String.t, String.t) :: {:ok, Response.t} | {:error, HTTPError.t}
  def get_access_token(consumer_key, request_token) do
    body = ~s({"consumer_key": "#{consumer_key}", "code": "#{request_token}"})
    HTTPotion.post(access_token_url, [body: body, headers: request_headers])
    |> handle_response
  end

  @doc """
  Requests an access token from the Pocket API.

  The method requires a `request_token` fetched from `Pocketeer.Auth.get_request_token`
  method.

  ## Examples

  ```
  Pocketeer.Auth.get_access_token(%{consumer_key: "abcd", request_token: "1234"})
  {:ok, Response{}}
  ```

  """
  @spec get_access_token(map) :: {:ok, map} | {:error, HTTPError.t}
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
