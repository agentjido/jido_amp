defmodule Jido.Amp.Agent do
  @moduledoc """
  Agent that manages a single Amp CLI session lifecycle.

  Routes SDK stream messages to the HandleMessage action and maintains
  session state (status, prompt, worker reference, last event).

  ## Signal Routes

    * `"amp.session.start"` → StartSession action
    * `"amp.internal.message"` → HandleMessage action

  ## Usage

      {:ok, _} = Jido.start()
      {:ok, pid} = Jido.start_agent(Jido.default_instance(), Jido.Amp.Agent, id: "amp-1")

      signal = Jido.Signal.new!(%{
        type: "amp.session.start",
        data: %{prompt: "Fix the failing test"}
      })

      {:ok, _agent} = Jido.AgentServer.call(pid, signal)
  """

  use Jido.Agent,
    name: "amp_session",
    description: "Manages a single Amp CLI agent session",
    schema: [
      status: [type: :atom, default: :idle],
      prompt: [type: :string, default: nil],
      session_id: [type: :string, default: nil],
      worker_pid: [type: :any, default: nil],
      started_at: [type: :any, default: nil],
      amp_event: [type: :any, default: nil],
      result: [type: :string, default: nil],
      error: [type: :any, default: nil]
    ]

  @dialyzer {:nowarn_function, plugin_specs: 0}

  @impl true
  def signal_routes(_ctx) do
    [
      {"amp.session.start", Jido.Amp.Actions.StartSession},
      {"amp.internal.message", Jido.Amp.Actions.HandleMessage}
    ]
  end
end
