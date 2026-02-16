defmodule Jido.Amp.StreamRunner do
  @moduledoc """
  Task that enumerates an AmpSdk stream and dispatches each message
  as a signal to the owning Agent.

  Spawned by the StartSession action. For each SDK message, wraps it
  in an `"amp.internal.message"` signal and dispatches to the agent PID.
  """

  require Logger

  alias AmpSdk.Types.ErrorResultMessage
  alias Jido.Amp.Compatibility
  alias Jido.Signal
  alias Jido.Signal.Dispatch

  @doc "Run the stream and dispatch messages to the agent."
  @spec run(map()) :: :ok
  def run(%{agent_pid: agent_pid, prompt: prompt, options: options} = args) do
    executor = Map.get(args, :executor, &AmpSdk.execute/2)
    compatibility_check = Map.get(args, :compatibility_check, &Compatibility.check/0)

    case compatibility_check.() do
      :ok ->
        prompt
        |> executor.(options)
        |> Stream.each(fn sdk_message ->
          dispatch_message(agent_pid, sdk_message)
        end)
        |> Stream.run()

      {:error, error} ->
        dispatch_error(agent_pid, error)
    end
  rescue
    e ->
      Logger.error("Amp StreamRunner error: #{Exception.message(e)}")
      dispatch_error(agent_pid, Exception.message(e))
  end

  defp dispatch_message(agent_pid, sdk_message) do
    signal =
      Signal.new!(%{
        type: "amp.internal.message",
        source: "/amp/stream_runner",
        data: %{message: sdk_message}
      })

    Dispatch.dispatch(signal, {:pid, target: agent_pid})
  end

  defp dispatch_error(agent_pid, %{message: message}) when is_binary(message) do
    dispatch_error(agent_pid, message)
  end

  defp dispatch_error(agent_pid, message) when is_binary(message) do
    error_signal =
      Signal.new!(%{
        type: "amp.internal.message",
        source: "/amp/stream_runner",
        data: %{message: %ErrorResultMessage{error: message, is_error: true}}
      })

    Dispatch.dispatch(error_signal, {:pid, target: agent_pid})
  end

  defp dispatch_error(agent_pid, reason) do
    dispatch_error(agent_pid, inspect(reason))
  end
end
