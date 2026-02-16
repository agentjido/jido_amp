defmodule Jido.Amp.Actions.HandleMessage do
  @moduledoc """
  Process a message from the AmpSdk stream.

  Routes each SDK message type to the appropriate state update and
  emits parent-facing signals for downstream consumers.
  """

  use Jido.Action,
    name: "amp_handle_message",
    description: "Process an Amp SDK stream message",
    schema: [
      message: [type: :any, required: true]
    ]

  alias Jido.Agent.Directive
  alias Jido.Amp.Signal

  alias AmpSdk.Types.{
    AssistantMessage,
    ErrorResultMessage,
    ResultMessage,
    SystemMessage,
    TextContent,
    ThinkingContent,
    ToolUseContent,
    UserMessage
  }

  @impl true
  def run(params, context) do
    agent = context[:agent]
    session_id = agent && agent.state[:session_id]

    {state_update, signals, terminal?} = process_message(params.message, session_id)

    directives = build_directives(agent, signals, terminal?)

    {:ok, Map.put(state_update, :amp_event, params.message), directives}
  end

  defp process_message(%SystemMessage{} = msg, _session_id) do
    state = %{
      session_id: msg.session_id
    }

    signal =
      Signal.session_started(%{
        session_id: msg.session_id,
        cwd: msg.cwd,
        tools: msg.tools
      })

    {state, [signal], false}
  end

  defp process_message(%AssistantMessage{} = msg, session_id) do
    resolved_session_id = resolve_session_id(msg.session_id, session_id)

    signals =
      msg.message.content
      |> Enum.flat_map(fn
        %TextContent{text: text} ->
          [Signal.assistant_text(resolved_session_id, text)]

        %ThinkingContent{thinking: thinking} ->
          [Signal.thinking(resolved_session_id, thinking)]

        %ToolUseContent{name: name, input: input} ->
          [Signal.tool_use(resolved_session_id, %{name: name, input: input})]

        _ ->
          []
      end)

    {%{}, signals, false}
  end

  defp process_message(%UserMessage{} = msg, session_id) do
    resolved_session_id = resolve_session_id(msg.session_id, session_id)
    signal = Signal.tool_result(resolved_session_id, %{content: msg.message.content})
    {%{}, [signal], false}
  end

  defp process_message(%ResultMessage{} = msg, _session_id) do
    state = %{
      status: :success,
      result: msg.result
    }

    signal =
      Signal.session_completed(%{
        session_id: msg.session_id,
        result: msg.result,
        num_turns: msg.num_turns,
        duration_ms: msg.duration_ms
      })

    {state, [signal], true}
  end

  defp process_message(%ErrorResultMessage{} = msg, _session_id) do
    state = %{
      status: :failure,
      error: msg.error
    }

    signal = Signal.session_failed(msg.session_id, msg.error)
    {state, [signal], true}
  end

  defp process_message(_unknown, _session_id) do
    {%{}, [], false}
  end

  defp resolve_session_id(message_session_id, fallback_session_id) do
    if is_binary(message_session_id) and message_session_id != "" do
      message_session_id
    else
      fallback_session_id
    end
  end

  defp build_directives(agent, signals, terminal?) do
    signal_directives =
      signals
      |> Enum.map(fn signal ->
        if agent do
          Directive.emit_to_parent(agent, signal)
        else
          Directive.emit(signal)
        end
      end)
      |> Enum.reject(&is_nil/1)

    if terminal? do
      signal_directives ++ [Directive.stop(:normal)]
    else
      signal_directives
    end
  end
end
