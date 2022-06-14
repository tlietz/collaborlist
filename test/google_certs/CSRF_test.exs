defmodule CSRFTests do
  use ExUnit.Case, async: true

  describe "verify CSRF token" do
    test "verify_csrf_token/2 returns {:ok, _} when CSRF token is valid" do
    end

    test "verify_csrf_token/2 returns {:error, msg} with `body` in msg when token is not in body" do
    end

    test "verify_csrf_token/2 returns {:error, msg} with `cookie` in msg when token is not in cookies" do
    end

    test "verify_csrf_token/2 returns {:error, msg} with `not match` in msg when token in body and cookies do not match" do
    end
  end
end
