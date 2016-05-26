defmodule Pocketeer.GetTest do
  use ExUnit.Case

  alias Pocketeer.Get

  doctest Pocketeer.Get

  test "get with invalid state" do
    options = Get.new(%{state: "foo"})
    assert Map.get(options, :state) == :unread
  end

  test "get without valid favorite property" do
    options = Get.new(%{favorite: "unused"})
    assert Map.get(options, :favorite) == nil
  end

  test "get with valid sort :oldest" do
    options = Get.new(%{sort: :oldest})
    assert Map.get(options, :sort) == :oldest
  end

  test "get with invalid sort" do
    options = Get.new(%{sort: :unknown})
    assert Map.get(options, :sort) == nil
  end
end
