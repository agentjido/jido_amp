defmodule Jido.Amp.Test.StubCLI do
  @moduledoc false

  def resolve do
    Application.get_env(:jido_amp, :stub_cli_resolve, fn -> {:ok, %{program: "/tmp/amp"}} end).()
  end
end

defmodule Jido.Amp.Test.StubCommand do
  @moduledoc false

  def run(args, opts \\ []) do
    Application.get_env(:jido_amp, :stub_command_run, fn _args, _opts -> {:ok, ""} end).(args, opts)
  end

  def run(_spec, args, opts) do
    run(args, opts)
  end
end

defmodule Jido.Amp.Test.StubAmpSdk do
  @moduledoc false

  alias AmpSdk.Types.ResultMessage

  def execute(input, options) do
    Application.get_env(:jido_amp, :stub_amp_sdk_execute, fn _input, _options ->
      [%ResultMessage{result: "stubbed"}]
    end).(input, options)
  end

  def run(prompt, options) do
    Application.get_env(:jido_amp, :stub_amp_sdk_run, fn _prompt, _options -> {:ok, "stubbed"} end).(
      prompt,
      options
    )
  end
end

defmodule Jido.Amp.Test.StubInstaller do
  @moduledoc false

  def ensure_installed(opts \\ []) do
    Application.get_env(:jido_amp, :stub_ensure_installed, fn _opts ->
      {:ok, %{status: :already_installed, program: "/tmp/amp"}}
    end).(opts)
  end
end
