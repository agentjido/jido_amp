defmodule Jido.Amp.Integration.AdapterLiveIntegrationTest do
  use ExUnit.Case, async: false
  use Jido.Amp.LiveIntegrationCase

  alias Jido.Amp.Adapter
  alias Jido.Harness.RunRequest

  @integration_skip_reason Jido.Amp.LiveIntegrationCase.skip_reason()

  if @integration_skip_reason do
    @moduletag skip: @integration_skip_reason
  end

  test "adapter emits a terminal harness event via the real Amp CLI", ctx do
    request =
      RunRequest.new!(%{
        prompt: ctx.prompt,
        cwd: ctx.cwd,
        timeout_ms: ctx.timeout_ms,
        metadata: %{}
      })

    assert {:ok, stream} = Adapter.run(request, ctx.adapter_opts)
    events = Enum.to_list(stream)

    assert events != []
    assert Enum.all?(events, &(&1.provider == :amp))
    assert Enum.any?(events, &(&1.type == :session_started))

    terminal =
      Enum.find(events, fn event ->
        event.type in [:session_completed, :session_failed]
      end)

    assert terminal

    if ctx.require_success? do
      assert terminal.type == :session_completed
    end
  end
end
