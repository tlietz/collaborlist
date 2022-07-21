defmodule CollaborlistWeb.InvitesControllerTest do
  use CollaborlistWeb.ConnCase

  import Collaborlist.CatalogFixtures

  alias CollaborlistWeb.UserAuth
  alias Collaborlist.Catalog
  alias Collaborlist.Invites

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: 4, checked: "foo", striked: "bar"}
end
