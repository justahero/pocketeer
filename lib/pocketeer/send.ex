defmodule Pocketeer.Send do
  @moduledoc """
  Modify one or more items via the Modify API endpoint by sending one or more actions.

  To generate actions use the `Pocketeer.Item` module.
  """

  import Pocketeer.HTTPHandler

  alias Pocketeer.Client

  @doc """
  Send a single action or a list of actions to Pocket's [Modify endpoint](https://getpocket.com/developer/docs/v3/modify).

  ## Examples

  It's possible to send a single action via a struct, see linked Pocket's API documentation.

  ```
  # archive a single item with a given id.
  client = Client.new("consumer_key", "access_token")
  Send.post(%{action: "archive", item_id: "1234"}, client)
  ```

  The Modify endpoint support a bulk operation, where several actions can be given as a list.

  ```
  client = Client.new("consumer_key", "access_token")
  items = [
    %{action: "favorite", item_id: "123"},
    %{action: "delete", item_id: "456"}
  ]
  Send.post(items, client)
  ```

  The best way to send actions to the API is by constructing them via `Pocketeer.Item`.

  ```
  # same as above
  client = Client.new("consumer_key", "access_token")
  items = Send.new |> Send.archive("123") |> Send.delete("456")
  Send.post(items, client)
  ```

  """
  @spec post(map | list | Item.t, Client.t) :: {:ok, Response.t} | {:error, HTTPError.t}
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
