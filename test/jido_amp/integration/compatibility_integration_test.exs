defmodule Jido.Amp.Integration.CompatibilityTest do
  use ExUnit.Case
  use Jido.Amp.LiveIntegrationCase

  alias Jido.Amp.Compatibility

  @integration_skip_reason Jido.Amp.LiveIntegrationCase.skip_reason()

  if @integration_skip_reason do
    @moduletag skip: @integration_skip_reason
  end

  test "compatibility check passes against the live CLI", ctx do
    assert :ok = Compatibility.check(ctx.cli_opts)
  end
end
