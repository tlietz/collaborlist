defmodule Collaborlist.ListFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Collaborlist.List` context.
  """

  import Collaborlist.CatalogFixtures

  @doc """
  Generates a list_item and a list, then adds the list_item to that list.
  """
  def list_item_fixture(attrs \\ %{}, list \\ list_fixture()) do
    {:ok, list_item} =
      attrs
      |> Enum.into(%{
        content: "some content",
        status: "none"
      })
      |> Collaborlist.List.create_list_item(list)

    list_item
  end
end
