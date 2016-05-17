defmodule Pocketeer.Client do
  import Pocketeer.HTTPHandler

  alias Pocketeer.HTTPHandler

  @type t :: %__MODULE__ {
    consumer_key: String.t,
    access_token: String.t,
    site: String.t
  }

  defstruct consumer_key: nil,
            access_token: nil,
            site: "https://getpocket.com"

  @doc """
  Creates a new Pocketeer client

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

  def new(options) do
    struct(__MODULE__, options)
  end
end
