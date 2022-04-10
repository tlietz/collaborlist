defmodule Collaborlist.ListFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Collaborlist.List` context.
  """

  @doc """
  Generate a list_item.
  """
  def list_item_fixture(attrs \\ %{}) do
    {:ok, list_item} =
      attrs
      |> Enum.into(%{
        content: "some content",
        order: 42
      })
      |> Collaborlist.List.create_list_item()

    list_item
  end
end
