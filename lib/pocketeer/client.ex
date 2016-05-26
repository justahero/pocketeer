defmodule Pocketeer.Client do
  @moduledoc """
  A simple Client struct to hold consumer key and access token for easier use with this library.
  """

  @type t :: %__MODULE__ {
    consumer_key: String.t,
    access_token: String.t,
    site: String.t
  }

  defstruct consumer_key: nil,
            access_token: nil,
            site: "https://getpocket.com"

  @doc """
  Builds a Client.

  ## Parameters

    - consumer_key: The consumer key received from the Pocket application page
    - access_token: The access token retrieved after successful authorization with Pocket

  ## Examples

      iex> Pocketeer.Client.new("1234", "abcd")
      %Pocketeer.Client{access_token: "abcd", consumer_key: "1234", site: "https://getpocket.com"}

  """
  @spec new(String.t, String.t) :: t
  def new(consumer_key, access_token) do
    %__MODULE__{
      consumer_key: consumer_key,
      access_token: access_token
    }
  end

  @doc """

  Builds a Client struct with `consumery_key` and `access_token`.

  ## Parameters

    - options: a map with `consumer_key` and `access_token`

  ## Examples

      iex> Pocketeer.Client.new(%{consumer_key: "1234", access_token: "abcd"})
      %Pocketeer.Client{access_token: "abcd", consumer_key: "1234", site: "https://getpocket.com"}

  """
  @spec new(map) :: t
  def new(%{consumer_key: _, access_token: _} = options) do
    struct(__MODULE__, options)
  end
end
