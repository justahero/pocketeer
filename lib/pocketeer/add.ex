defmodule Pocketeer.Add do
  @moduledoc """
  This module implements the Add endpoint of the Pocket API.
  """

  import Pocketeer.HTTPHandler
  alias Pocketeer.Add

  @spec add(Client.t, map) :: {:ok, Response.t} | {:error, HTTPError.t}
  def add(client, %{url: url} = options) do
    args = default_args(client, options |> parse_options)
    HTTPotion.post("#{client.site}/v3/add", args)
    |> handle_response
  end

  defp parse_options(%{tags: tags} = options) do
    %{options | tags: Enum.join(tags, ", ")}
  end
  defp parse_options(%{} = options) do options end
end
