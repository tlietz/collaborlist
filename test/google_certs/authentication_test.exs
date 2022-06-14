defmodule AuthenticationTests do
  use ExUnit.Case, async: true

  describe "verify jwt" do
    test "verify_id_token/2 returns {:ok, _} when jwt is valid " do
    end

    test "verify_id_token/2 returns {:error, msg} with `signature` in msg when jwt signature fails" do
    end

    test "verify_id_token/2 returns {:error, msg} with `aud` in msg when jwt `aud` field is wrong" do
    end

    test "verify_id_token/2 returns {:error, msg} with `iss` in msg when jwt `iss` field is wrong" do
    end

    test "verify_id_token/2 returns {:error, msg} with `expired` when jwt is expired" do
    end
  end
end
