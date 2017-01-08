defmodule Pocketeer.Item do
  @moduledoc """
  Builds structs for use with the [Modify API](https://getpocket.com/developer/docs/v3/modify),
  to modify items.

  The Pocket API allows to modify multiple items at once in a bulk operation. For this
  several `Item` actions can be created directly or chained via pipe operator.

  **Note** an `Item` struct then can be used with the `Pocketeer.send/2` functions
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

  alias Pocketeer.Item

  import Pocketeer.TagsHelper

  @url_options  [:url, :tags, :title, :tweet_id]
  @item_options [:item_id, :tags, :title, :tweet_id]

  @typedoc """
  A list of actions that can be send via `Pocketeer.send/2`
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

  ## Parameters

    * `options` - A map of options, requires `url` or `item_id` to be present.
      Accepts the same parameters as the `Pocketeer.Add` module.

  ## Examples

      iex> Item.add(%{url: "http://hex.pm"})
      %{action: "add", url: "http://hex.pm"}

      iex> Item.add(%{item_id: "1234"})
      %{action: "add", item_id: "1234"}

  """
  def add(%{url: _} = options) do
    {options, _} = Map.split(options, @url_options)
    Map.merge(%{action: "add"}, options)
  end
  def add(%{item_id: _} = options) do
    {options, _} = Map.split(options, @item_options)
    Map.merge(%{action: "add"}, options)
  end

  @doc """
  Used to return a new list from the existing item

  ## Parameters

    * `item` - a `Pocketeer.Item` struct with options
    * `id` - the item id

  ## Examples

      iex> Item.new |> Item.add(%{url: "http://foo.com"})
      %Item{actions: [%{action: "add", url: "http://foo.com"}]}

  """
  @spec add(t, map) :: t
  def add(%Item{} = item, %{} = options) do append(item, [add(options)]) end

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

  @doc """
  Adds one or more tags to an item.
  """
  def tags_add(item_id, tags) when is_binary(item_id) do
    %{action: "tags_add", item_id: item_id, tags: parse_tags(tags)}
  end
  def tags_add(ids, tags) when is_list(ids) do map(ids, tags, &tags_add/2) end
  def tags_add(%Item{} = item, id, tags) do append(item, [tags_add(id, tags)]) end

  @doc """
  Removes one or more tags from an item.
  """
  def tags_remove(item_id, tags) when is_binary(item_id) do
    %{action: "tags_remove", item_id: item_id, tags: parse_tags(tags)}
  end
  def tags_remove(ids, tags) when is_list(ids) do map(ids, tags, &tags_remove/2) end
  def tags_remove(%Item{} = item, id, tags) do append(item, [tags_remove(id, tags)]) end

  @doc """
  Replaces all of the tags of an item with the new tag or list of tags
  """
  def tags_replace(item_id, tags) when is_binary(item_id) do
    %{action: "tags_replace", item_id: item_id, tags: parse_tags(tags)}
  end
  def tags_replace(ids, tags) when is_list(ids) do map(ids, tags, &tags_replace/2) end
  def tags_replace(%Item{} = item, id, tags) do append(item, [tags_replace(id, tags)]) end

  @doc """
  Removes all tags from an item.
  """
  def tags_clear(item_id) when is_binary(item_id) do
    %{action: "tags_clear", item_id: item_id}
  end
  def tags_clear(ids) when is_list(ids) do map(ids, &tags_clear/1) end
  def tags_clear(%Item{} = item, id) do append(item, [tags_clear(id)]) end

  @doc """
  Renames a tag, note this affects all items that have this tag.
  """
  def tag_rename(old_tag, new_tag) do
    %{action: "tag_rename", old_tag: old_tag, new_tag: new_tag}
  end
  def tag_rename(%Item{} = item, old_tag, new_tag) do
    append(item, [tag_rename(old_tag, new_tag)])
  end

  # Private methods

  defp map(ids, function) do
    Enum.map(ids, fn id -> function.(id) end)
  end

  defp map(ids, tags, function) do
    Enum.map(ids, fn id -> function.(id, tags) end)
  end

  defp append(%Item{} = item, actions) when is_list(actions) do
    Item.new(item.actions ++ actions)
  end
end
