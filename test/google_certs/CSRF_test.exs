defmodule CSRFTests do
  use ExUnit.Case, async: true

  describe "verify CSRF token" do
    test "verify_csrf_token/2 returns {:ok, _} when CSRF token is valid" do
    end

    test "verify_csrf_token/2 returns {:error, _} when CSRF token is invalid" do
    end
  end
end
