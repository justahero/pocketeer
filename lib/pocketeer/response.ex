defmodule Pocketeer.Response do
  @type stats   :: integer
  @type body    :: String.t
  @type headers :: Array.t

  defstruct status: nil,
            body: "",
            headers: []
end
