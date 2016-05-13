defmodule Pocketeer do
  defmodule HTTPError do
    defexception [:message]
  end

  defmodule Error do
    defexception [:message]
  end
end
