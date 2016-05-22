defmodule Pocketeer.Send do
  @moduledoc false

  import Pocketeer.HTTPHandler

  alias Pocketeer.Client
  alias Pocketeer.Send

  @options [:url, :tags, :title, :tweet_id]

  @type t :: %__MODULE__ {
    actions: list
  }

  defstruct actions: []

  def new do
    %__MODULE__{actions: []}
  end

  def new(actions) when is_list(actions) do
    %__MODULE__{actions: actions}
  end

  @spec new(map) :: t
  def new(options) when is_map(options) do
    struct(__MODULE__, options)
  end

  def add(%{url: _} = options) do
    {options, _} = Dict.split(options, [:url, :tags, :title, :tweet_id])
    [Map.merge(%{action: "add"}, options)]
  end

  def add(%{item_id: _} = options) do
    {options, _} = Dict.split(options, [:item_id, :tags, :title, :tweet_id])
    [Map.merge(%{action: "add"}, options)]
  end

  def add(%Send{} = send, options) do
    Send.new(send.actions ++ add(options))
  end

  def archive(item_id) when is_binary(item_id) do
    [%{action: "archive", item_id: item_id}]
  end

  def archive(item_ids) when is_list(item_ids) do
    Enum.map(item_ids, fn id -> archive(id) end)
  end

  def archive(%Send{} = send, items)  do
    Send.new(send.actions ++ archive(items))
  end

  def unarchive(item_id) when is_binary(item_id) do
    [%{action: "readd", item_id: item_id}]
  end

  def unarchive(item_ids) when is_list(item_ids) do
    Enum.map(item_ids, fn id -> unarchive(id) end)
  end

  def unarchive(%Send{} = send, items)  do
    Send.new(send.actions ++ unarchive(items))
  end

  def favorite(item_id) when is_binary(item_id) do
    [%{action: "favorite", item_id: item_id}]
  end

  def favorite(item_ids) when is_list(item_ids) do
    Enum.map(item_ids, fn id -> favorite(id) end)
  end

  def favorite(%Send{} = send, items)  do
    Send.new(send.actions ++ favorite(items))
  end

  def unfavorite(item_id) when is_binary(item_id) do
    [%{action: "unfavorite", item_id: item_id}]
  end

  def unfavorite(item_ids) when is_list(item_ids) do
    Enum.map(item_ids, fn id -> unfavorite(id) end)
  end

  def unfavorite(%Send{} = send, items)  do
    Send.new(send.actions ++ unfavorite(items))
  end

  def delete(item_id) when is_binary(item_id) do
    [%{action: "delete", item_id: item_id}]
  end

  def delete(item_ids) when is_list(item_ids) do
    Enum.map(item_ids, fn id -> delete(id) end)
  end

  def delete(%Send{} = send, items)  do
    Send.new(send.actions ++ delete(items))
  end

  def post(actions, %Client{} = client) when is_list(actions) do
    post(Send.new(actions), client)
  end

  def post(%Send{} = send, %Client{} = client) do
    actions = %{actions: parse_actions(send.actions)}
    body = build_body(client, actions)
    HTTPotion.post("#{client.site}/v3/send", [body: body, headers: request_headers])
    |> handle_response
  end

  def post(action, %Client{} = client) when is_map(action) do
    post(Send.new([action]), client)
  end

  defp parse_actions(actions) do
    actions
    |> List.flatten
    |> Enum.map(fn action -> Map.put(action, :timestamp, timestamp) end)
  end
end
