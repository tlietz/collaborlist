defmodule Collaborlist.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Collaborlist.Catalog` context.
  """

  @doc """
  Generate a list.
  """
  def list_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        title: "some title"
      })

    {:ok, list} =
      Collaborlist.AccountFixtures.user_fixture() |> Collaborlist.Catalog.create_list(attrs)

    list
  end
end
