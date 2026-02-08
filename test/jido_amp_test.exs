defmodule Jido.AmpTest do
  use ExUnit.Case
  doctest Jido.Amp

  describe "version/0" do
    test "returns the version" do
      version = Jido.Amp.version()
      assert is_binary(version)
      assert version =~ ~r/^\d+\.\d+\.\d+$/
    end
  end
end
