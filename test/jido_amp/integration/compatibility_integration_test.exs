defmodule Jido.Amp.Integration.CompatibilityTest do
  use ExUnit.Case

  alias Jido.Amp.Compatibility

  @moduletag :integration

  test "compatibility check runs against local environment" do
    result = Compatibility.check()
    assert result == :ok or match?({:error, _}, result)
  end
end
