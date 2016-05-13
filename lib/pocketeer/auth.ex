defmodule Pocketeer.Auth do
  @request_token_url "https://getpocket.com/v3/oauth/request"
  @authorization_url "https://getpocket.com/v3/uauth/authorize"

  @request_headers [{"Content-Type", "application/json; charset=UTF-8"}, {"X-Accept", "application/json"}]

  @doc """
  Sends a GET request to fetch a request token

  ## Parameters:

    - consumer_key: The consumer key given by Pocket

  ## Examples:

      iex> consumer_key = Application.get_env(:pocketeer, :consumer_key, "123")
      iex> Pocketeer.Auth.get_request_token(consumer_key, "localhost")
      {:ok, {}}

  Raises `Pocketeer.HTTPError` if request fails
  """
  @spec get_request_token(String.t, String.t) :: {:ok, Response.t} | {:error, HTTPError.t}
  def get_request_token(consumer_key, redirect_uri, state \\ nil) do
    body = ~s({"consumer_key": "#{consumer_key}", "redirect_uri": "#{redirect_uri}"})
    response = HTTPotion.post(@request_token_url, [body: body, headers: @request_headers])
    {:ok, {}}
  end
end
