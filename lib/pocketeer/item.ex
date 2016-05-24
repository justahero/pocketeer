require IEx

defmodule Pocketeer.Item do
  alias Pocketeer.Item

  @moduledoc """
  This module can be used to build item actions for the Modify endpoint.

  The Pocket API allows to modify multiple items at once in a bulk operation. For this
  several `Item` actions can be created directly or chained via pipe.

  **Note**, the built action or list of actions can be used with the `Pocketeer.Send` functions
  to modify items.

  ## Examples

      # single action
      iex> Item.archive("1234")
      %{action: "archive", item_id: "1234"}

      # multiple items of same action
      iex> Item.favorite(["abcd", "9876"])
      [%{action: "favorite", item_id: "abcd"}, %{action: "favorite", item_id: "9876"}]

      # chained list of actions, can be combined as wished
      iex> items = Item.new |> Item.favorite("2") |> Item.delete("3")
      %Item{actions: [%{action: "favorite", item_id: "2"}, %{action: "delete", item_id: "3"}]}
      iex> items.actions
      [%{action: "favorite", item_id: "2"}, %{action: "delete", item_id: "3"}]

  """

  @url_options  [:url, :tags, :title, :tweet_id]
  @item_options [:item_id, :tags, :title, :tweet_id]

  @typedoc """
  A list of actions that can be send via `Pocketeer.Send`
  """
  @type t :: %__MODULE__ {
    actions: list
  }

  defstruct actions: []

  def new do new([]) end
  def new(action) when is_map(action) do new([action]) end
  def new(actions) when is_list(actions) do
    %__MODULE__{actions: List.flatten(actions)}
  end

  @doc """
  Returns a struct for adding an item to Pocket with an `url` or an `item_id`.
  Alternatively a list of existing item ids can be given.

  ## Examples

      iex> Item.add(%{url: "http://hex.pm"})
      %{action: "add", url: "http://hex.pm"}

      iex> Item.add(%{item_id: "1234"})
      %{action: "add", item_id: "1234"}

  """
  def add(%{url: _} = options) do
    {options, _} = Dict.split(options, @url_options)
    Map.merge(%{action: "add"}, options)
  end
  def add(%{item_id: _} = options) do
    {options, _} = Dict.split(options, @item_options)
    Map.merge(%{action: "add"}, options)
  end

  @doc """
  Used to return a new list from the existing item
  """
  def add(%Item{} = item, id) do append(item, [add(id)]) end

  @doc """
  Archives the given item or items.
  """
  def archive(id) when is_binary(id) do
    %{action: "archive", item_id: id}
  end
  def archive(ids) when is_list(ids) do map(ids, &archive/1) end
  def archive(%Item{} = item, id) do append(item, [archive(id)]) end

  @doc """
  Readds or unarchives the given item or items.
  """
  def unarchive(item_id) when is_binary(item_id) do
    %{action: "readd", item_id: item_id}
  end
  def unarchive(ids) when is_list(ids) do map(ids, &unarchive/1) end
  def unarchive(%Item{} = item, id) do append(item, [unarchive(id)]) end

  @doc """
  Marks the given item or items as favorite.
  """
  def favorite(item_id) when is_binary(item_id) do
    %{action: "favorite", item_id: item_id}
  end
  def favorite(ids) when is_list(ids) do map(ids, &favorite/1) end
  def favorite(%Item{} = item, id) do append(item, [favorite(id)]) end

  @doc """
  Removes fav / unfavorites the given item or items.
  """
  def unfavorite(item_id) when is_binary(item_id) do
    %{action: "unfavorite", item_id: item_id}
  end
  def unfavorite(ids) when is_list(ids) do map(ids, &unfavorite/1) end
  def unfavorite(%Item{} = item, id) do append(item, [unfavorite(id)]) end

  @doc """
  Deletes the given item or items.
  """
  def delete(item_id) when is_binary(item_id) do
    %{action: "delete", item_id: item_id}
  end
  def delete(ids) when is_list(ids) do map(ids, &delete/1) end
  def delete(%Item{} = item, id) do append(item, [delete(id)]) end

  # Private methods

  defp map(ids, function) do
    Enum.map(ids, fn id -> function.(id) end)
  end

  defp append(%Item{} = item, actions) when is_list(actions) do
    Item.new(item.actions ++ actions)
  end
end
