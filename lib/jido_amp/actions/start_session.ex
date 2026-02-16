defmodule Jido.Amp.Actions.StartSession do
  @moduledoc """
  Start an Amp CLI agent session.

  Spawns a StreamRunner task that enumerates the AmpSdk stream and dispatches
  messages back to the agent as internal signals.

  ## Parameters

    * `prompt` - Required. The prompt to send to Amp.
    * `options` - Optional map of Amp SDK options.

  Legacy flat options (`cwd`, `mode`, etc.) are still accepted and merged
  into `options`.
  """

  use Jido.Action,
    name: "amp_start_session",
    description: "Start an Amp CLI agent session",
    schema: [
      prompt: [type: :string, required: true],
      options: [type: :map, default: %{}],
      cwd: [type: :string, default: nil],
      mode: [type: :string, default: "smart"],
      dangerously_allow_all: [type: :boolean, default: false],
      stream_timeout_ms: [type: :pos_integer, default: 120_000]
    ]

  alias Jido.Agent.Directive
  alias Jido.Amp.Options

  @impl true
  def run(params, context) do
    agent_pid = context[:agent_pid] || self()
    stream_runner = context[:stream_runner] || stream_runner_module()
    session_id = "amp-" <> Base.encode16(:crypto.strong_rand_bytes(4), case: :lower)

    options = build_options(params)

    runner_spec =
      {Task,
       fn ->
         stream_runner.run(%{
           agent_pid: agent_pid,
           prompt: params.prompt,
           options: options
         })
       end}

    result = %{
      status: :running,
      session_id: session_id,
      prompt: params.prompt,
      started_at: DateTime.utc_now()
    }

    directives = [
      Directive.spawn(runner_spec, :stream_runner)
    ]

    {:ok, result, directives}
  end

  defp build_options(params) do
    params
    |> merge_legacy_options()
    |> Options.to_amp_options!()
  end

  defp merge_legacy_options(params) do
    legacy =
      params
      |> Map.take([:cwd, :mode, :dangerously_allow_all, :stream_timeout_ms])
      |> Enum.reject(fn {_key, value} -> is_nil(value) end)
      |> Map.new()

    params
    |> Map.get(:options, %{})
    |> Map.merge(legacy)
    |> Map.put_new(:cwd, File.cwd!())
  end

  defp stream_runner_module do
    Application.get_env(:jido_amp, :stream_runner_module, Jido.Amp.StreamRunner)
  end
end
