defmodule Collaborlist.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Collaborlist.Catalog` context.
  """

  import Collaborlist.AccountFixtures

  @doc """
  Generate a list.
  """
  def list_fixture(attrs \\ %{}, user \\ user_fixture()) do
    attrs =
      attrs
      |> Enum.into(%{
        title: "some title"
      })

    {:ok, list} = user |> Collaborlist.Catalog.create_list(attrs)

    list
  end
end
