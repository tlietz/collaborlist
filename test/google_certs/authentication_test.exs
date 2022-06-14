defmodule AuthenticationTests do
  use ExUnit.Case, async: true

  describe "verify jwt" do
    test "verify_id_token/2 returns {:ok, _} when jwt is valid " do
    end

    test "verify_csrf_token/2 returns {:error, _} when jwt is invalid" do
    end
  end
end
