require IEx

defmodule Pocketeer.Item do
  alias Pocketeer.Item

  @type t :: %__MODULE__ {
    actions: list
  }

  defstruct actions: []

  def new do
    %__MODULE__{actions: []}
  end

  def new(action) when is_map(action) do
    %__MODULE__{actions: [action]}
  end

  def new(actions) when is_list(actions) do
    %__MODULE__{actions: List.flatten(actions)}
  end

  def archive(id) when is_binary(id) do
    %{action: "archive", item_id: id}
  end
  def archive(ids) when is_list(ids) do map(ids, &archive/1) end
  def archive(%Item{} = item, id) do append(item, [archive(id)]) end


  # Private methods

  defp map(ids, function) do
    Enum.map(ids, fn id -> function.(id) end)
  end

  defp append(%Item{} = item, actions) when is_list(actions) do
    Item.new(item.actions ++ actions)
  end
end
