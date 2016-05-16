defmodule Pocketeer.Client do
  @type t :: %__MODULE__ {
    consumer_key: String.t,
    access_token: String.t
  }

  defstruct consumer_key: nil,
            access_token: nil

  @doc """
  Creates a new Pocketeer client

  ## Parameters

    - consumer_key: The consumer key received from the Pocket application page
    - access_token: The access token retrieved after successful authorization with Pocket

  """
  @spec new(String.t, String.t) :: t
  def new(consumer_key, access_token) do
    %__MODULE__{
      consumer_key: consumer_key,
      access_token: access_token
    }
  end
end
