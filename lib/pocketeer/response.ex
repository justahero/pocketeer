defmodule Pocketeer.Response do
  @type status  :: integer
  @type headers :: map
  @type body    :: String.t

  @type t :: %__MODULE__{
    status: status,
    headers: headers,
    body: body
  }

  defstruct status: nil, headers: %{}, body: nil

  @doc false
  def new(status, headers, body) do
    %__MODULE__{
      status: status,
      headers: headers,
      body: body
    }
  end
end
