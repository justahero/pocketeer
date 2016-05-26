defmodule Pocketeer.TagsHelper do
  @moduledoc false

  def parse_tags(tags) when is_list(tags) do Enum.join(tags, ", ") end
  def parse_tags(tags) when is_binary(tags) do tags end
  def parse_tags(tags) when is_atom(tags) do to_string(tags) end
end
