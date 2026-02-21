defmodule Jido.Amp.AdapterTest do
  use ExUnit.Case, async: false

  use Jido.Harness.AdapterContract,
    adapter: Jido.Amp.Adapter,
    provider: :amp,
    check_run: true,
    run_request: %{prompt: "contract amp run", cwd: "/repo", metadata: %{}}

  alias AmpSdk.Types.{AssistantMessage, AssistantPayload, ResultMessage, SystemMessage, TextContent}
  alias Jido.Amp.Adapter
  alias Jido.Amp.Test.StubAmpSdk
  alias Jido.Harness.RunRequest

  defmodule StubCompatibility do
    def check(opts \\ []) do
      Application.get_env(:jido_amp, :stub_adapter_compat_check, fn _opts -> :ok end).(opts)
    end
  end

  setup do
    old_compat = Application.get_env(:jido_amp, :compatibility_module)
    old_sdk = Application.get_env(:jido_amp, :amp_sdk_module)
    old_check = Application.get_env(:jido_amp, :stub_adapter_compat_check)
    old_execute = Application.get_env(:jido_amp, :stub_amp_sdk_execute)

    Application.put_env(:jido_amp, :compatibility_module, StubCompatibility)
    Application.put_env(:jido_amp, :amp_sdk_module, StubAmpSdk)
    Application.put_env(:jido_amp, :stub_adapter_compat_check, fn _opts -> :ok end)

    Application.put_env(:jido_amp, :stub_amp_sdk_execute, fn prompt, _options ->
      send(self(), {:amp_execute, prompt})

      [
        %SystemMessage{session_id: "amp-session-1", cwd: "/repo", tools: ["Read", "Bash"]},
        %AssistantMessage{
          session_id: "amp-session-1",
          message: %AssistantPayload{
            content: [%TextContent{text: "Working on it"}]
          }
        },
        %ResultMessage{
          session_id: "amp-session-1",
          result: "Done",
          subtype: "success",
          is_error: false
        }
      ]
    end)

    on_exit(fn ->
      restore_env(:jido_amp, :compatibility_module, old_compat)
      restore_env(:jido_amp, :amp_sdk_module, old_sdk)
      restore_env(:jido_amp, :stub_adapter_compat_check, old_check)
      restore_env(:jido_amp, :stub_amp_sdk_execute, old_execute)
    end)

    :ok
  end

  test "id/0 and capabilities/0" do
    assert Adapter.id() == :amp
    caps = Adapter.capabilities()
    assert caps.streaming? == true
    assert caps.tool_calls? == true
  end

  test "runtime_contract/0 exposes amp runtime requirements" do
    contract = Adapter.runtime_contract()
    assert contract.provider == :amp
    assert "AMP_API_KEY" in contract.host_env_required_any
    assert "amp" in contract.runtime_tools_required
  end

  test "run/2 maps amp sdk stream to harness events" do
    request = RunRequest.new!(%{prompt: "ship it", cwd: "/repo", metadata: %{}})
    assert {:ok, stream} = Adapter.run(request)
    events = Enum.to_list(stream)

    assert_receive {:amp_execute, "ship it"}
    assert Enum.map(events, & &1.type) == [:session_started, :output_text_delta, :session_completed]
    assert Enum.all?(events, &(&1.provider == :amp))
  end

  test "run/2 returns compatibility errors" do
    Application.put_env(:jido_amp, :stub_adapter_compat_check, fn _opts ->
      {:error, Jido.Amp.Error.config_error("incompatible", %{key: :amp_cli})}
    end)

    request = RunRequest.new!(%{prompt: "hello", metadata: %{}})
    assert {:error, %Jido.Amp.Error.ConfigError{key: :amp_cli}} = Adapter.run(request)
  end

  defp restore_env(app, key, nil), do: Application.delete_env(app, key)
  defp restore_env(app, key, value), do: Application.put_env(app, key, value)
end
