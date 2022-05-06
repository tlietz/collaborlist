defmodule GoogleCertsTest do
  use ExUnit.Case, async: true

  describe "genserver" do
    test "start_link initializes genserver state with google cert keys" do
      GoogleCerts.start_link([])

      GoogleCerts.keys()
      |> IO.inspect(label: "KEYS")

      # raise "temp fail"
    end
  end
end
