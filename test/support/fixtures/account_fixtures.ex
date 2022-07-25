defmodule Collaborlist.AccountFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Collaborlist.Account` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"
  def example_google_uid, do: "#{Ecto.UUID.generate()}"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def valid_google_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      google_uid: example_google_uid()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Collaborlist.Account.register_user()

    user
  end

  def guest_user_fixture() do
    {:ok, guest_user} = Collaborlist.Account.register_guest_user()

    guest_user
  end

  def google_user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_google_user_attributes()
      |> Collaborlist.Account.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
