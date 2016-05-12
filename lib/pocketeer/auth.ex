defmodule Pocketeer.Auth do
  @request_token_url "https://getpocket.com/v3/oauth/request"
  @authorization_url "https://getpocket.com/v3/uauth/authorize"

  @doc """
  Sends a GET request to fetch a request token

  ## Parameters:

    - consumer_key: The consumer key given by Pocket

  ## Examples:

      iex> consumer_key = Application.get_env(:pocketeer, :consumer_key)
      iex> Pocketeer.Auth.get_request_token(consumer_key)
      ""

  Raises `Pocketeer.HTTPError` if request fails
  """
  def get_request_token(consumer_key) do
    ""
  end
end
