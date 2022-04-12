defmodule Collaborlist.ListFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Collaborlist.List` context.
  """

  import Collaborlist.CatalogFixtures

  @doc """
  Generates a list_item and a list, then adds the list_item to that list.
  """
  def list_item_fixture(attrs \\ %{}) do
    list = list_fixture()

    {:ok, list_item} =
      attrs
      |> Enum.into(%{
        content: "some content",
        checked: false,
        striked: false
      })
      |> Collaborlist.List.create_list_item(list)

    list_item
  end
end
