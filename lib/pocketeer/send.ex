defmodule Pocketeer.Send do
  @moduledoc false

  import Pocketeer.HTTPHandler

  alias Pocketeer.Client
  alias Pocketeer.Item
  alias Pocketeer.Send

  def post(%Item{} = item, %Client{} = client) do
    actions = %{actions: parse_actions(item.actions)}
    body = build_body(client, actions)
    HTTPotion.post("#{client.site}/v3/send", [body: body, headers: request_headers])
    |> handle_response
  end

  def post(action, %Client{} = client) when is_map(action) do
    post(Item.new(action), client)
  end

  def post(actions, %Client{} = client) when is_list(actions) do
    post(Item.new(actions), client)
  end

  defp parse_actions(actions) do
    actions
    |> List.flatten
    |> Enum.map(fn action -> Map.put(action, :timestamp, timestamp) end)
  end
end
