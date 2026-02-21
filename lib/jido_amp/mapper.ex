defmodule Jido.Amp.Mapper do
  @moduledoc """
  Maps Amp SDK stream messages into normalized `Jido.Harness.Event` structs.
  """

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

  alias Jido.Harness.Event

  @doc """
  Maps a single Amp SDK message into one or more normalized harness events.
  """
  @spec map_event(term()) :: {:ok, [Event.t()]} | {:error, term()}
  def map_event(%SystemMessage{} = message) do
    payload = %{
      "cwd" => message.cwd,
      "tools" => message.tools
    }

    {:ok, [build_event(:session_started, message.session_id, payload, message)]}
  end

  def map_event(%AssistantMessage{} = message) do
    session_id = message.session_id

    events =
      ((message.message && message.message.content) || [])
      |> Enum.flat_map(fn
        %TextContent{text: text} when is_binary(text) ->
          [build_event(:output_text_delta, session_id, %{"text" => text}, message)]

        %ThinkingContent{thinking: thinking} when is_binary(thinking) ->
          [build_event(:thinking_delta, session_id, %{"text" => thinking}, message)]

        %ToolUseContent{name: name, input: input} ->
          [
            build_event(
              :tool_call,
              session_id,
              %{"name" => name, "input" => input || %{}},
              message
            )
          ]

        _ ->
          []
      end)

    {:ok, events}
  end

  def map_event(%UserMessage{} = message) do
    payload = %{
      "content" => message.message && message.message.content
    }

    {:ok, [build_event(:tool_result, message.session_id, payload, message)]}
  end

  def map_event(%ResultMessage{} = message) do
    payload = %{
      "result" => message.result,
      "num_turns" => message.num_turns,
      "duration_ms" => message.duration_ms
    }

    {:ok, [build_event(:session_completed, message.session_id, payload, message)]}
  end

  def map_event(%ErrorResultMessage{} = message) do
    payload = %{
      "error" => message.error,
      "is_error" => true
    }

    {:ok, [build_event(:session_failed, message.session_id, payload, message)]}
  end

  def map_event(raw) do
    {:ok, [build_event(:provider_event, nil, %{"value" => inspect(raw)}, raw)]}
  end

  defp build_event(type, session_id, payload, raw) do
    Event.new!(%{
      type: type,
      provider: :amp,
      session_id: session_id,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      payload: stringify_keys(payload),
      raw: raw
    })
  end

  defp stringify_keys(map) when is_map(map) do
    map
    |> Enum.map(fn {k, v} -> {to_string(k), stringify_keys(v)} end)
    |> Map.new()
  end

  defp stringify_keys(list) when is_list(list), do: Enum.map(list, &stringify_keys/1)
  defp stringify_keys(value), do: value
end
