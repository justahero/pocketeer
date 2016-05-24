defmodule Pocketeer.ItemTest do
  use ExUnit.Case, async: false

  alias Pocketeer.Item
  doctest Pocketeer.Item

  test "add single item with url" do
    item = Item.add(%{url: "http://example.com"})
    assert item == %{action: "add", url: "http://example.com"}
  end

  test "add single item with item id" do
    item = Item.add(%{item_id: "1"})
    assert item == %{action: "add", item_id: "1"}
  end

  test "archive single item" do
    item = Item.archive("1")
    assert item == %{action: "archive", item_id: "1"}
  end

  test "favorite multiple entries in list" do
    actual = Item.favorite(["2", "3"])
    expected = [
      %{action: "favorite", item_id: "2"},
      %{action: "favorite", item_id: "3"}
    ]

    assert actual == expected
  end

  test "archive multiple entries" do
    actual = Item.new
            |> Item.archive("1")
            |> Item.archive("2")
    expected = [
      %{action: "archive", item_id: "1"},
      %{action: "archive", item_id: "2"}
    ]

    assert actual.actions == expected
  end

  test "build multiple items" do
    actual = Item.new
             |> Item.favorite(["1234", "2345"])
             |> Item.unfavorite("9876")
    expected = [
      %{action: "favorite", item_id: "1234"},
      %{action: "favorite", item_id: "2345"},
      %{action: "unfavorite", item_id: "9876"}
    ]

    assert actual.actions == expected
  end
end
