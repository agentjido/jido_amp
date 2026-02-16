defmodule Jido.Amp.Test.Fixtures do
  @moduledoc """
  AmpSdk message fixtures for Jido.Amp tests.
  """

  alias AmpSdk.Types.{
    AssistantMessage,
    AssistantPayload,
    ErrorResultMessage,
    ResultMessage,
    SystemMessage,
    TextContent,
    ThinkingContent,
    ToolResultContent,
    ToolUseContent,
    Usage,
    UserMessage,
    UserPayload
  }

  # ── System Messages ──

  def system_message(overrides \\ %{}) do
    Map.merge(
      %SystemMessage{
        type: "system",
        subtype: "init",
        session_id: "session-abc123",
        cwd: "/tmp/project",
        tools: ["Read", "Write", "Bash"],
        mcp_servers: []
      },
      overrides
    )
  end

  # ── Assistant Messages ──

  def assistant_text_message(text \\ "Hello from Amp!", overrides \\ %{}) do
    Map.merge(
      %AssistantMessage{
        type: "assistant",
        session_id: "session-abc123",
        message: %AssistantPayload{
          role: "assistant",
          model: "claude-sonnet-4-20250514",
          content: [%TextContent{type: "text", text: text}],
          stop_reason: "end_turn",
          usage: %Usage{input_tokens: 100, output_tokens: 50}
        },
        parent_tool_use_id: nil
      },
      overrides
    )
  end

  def assistant_tool_use_message(name \\ "Read", input \\ %{"path" => "/tmp/file.txt"}) do
    %AssistantMessage{
      type: "assistant",
      session_id: "session-abc123",
      message: %AssistantPayload{
        role: "assistant",
        model: "claude-sonnet-4-20250514",
        content: [
          %ToolUseContent{
            type: "tool_use",
            id: "tool-use-001",
            name: name,
            input: input
          }
        ],
        stop_reason: "tool_use",
        usage: %Usage{input_tokens: 200, output_tokens: 80}
      }
    }
  end

  def assistant_thinking_message(thinking \\ "Analyzing constraints...") do
    %AssistantMessage{
      type: "assistant",
      session_id: "session-abc123",
      message: %AssistantPayload{
        role: "assistant",
        model: "claude-sonnet-4-20250514",
        content: [%ThinkingContent{type: "thinking", thinking: thinking}],
        stop_reason: "end_turn",
        usage: %Usage{input_tokens: 120, output_tokens: 40}
      }
    }
  end

  def assistant_mixed_content_message do
    %AssistantMessage{
      type: "assistant",
      session_id: "session-abc123",
      message: %AssistantPayload{
        role: "assistant",
        model: "claude-sonnet-4-20250514",
        content: [
          %TextContent{type: "text", text: "Let me read that file."},
          %ToolUseContent{
            type: "tool_use",
            id: "tool-use-002",
            name: "Read",
            input: %{"path" => "/tmp/data.json"}
          },
          %TextContent{type: "text", text: "Now let me write the output."}
        ],
        stop_reason: "tool_use"
      }
    }
  end

  def assistant_empty_content_message do
    %AssistantMessage{
      type: "assistant",
      session_id: "session-abc123",
      message: %AssistantPayload{
        role: "assistant",
        content: []
      }
    }
  end

  # ── User Messages ──

  def user_tool_result_message(overrides \\ %{}) do
    Map.merge(
      %UserMessage{
        type: "user",
        session_id: "session-abc123",
        message: %UserPayload{
          role: "user",
          content: [
            %ToolResultContent{
              type: "tool_result",
              tool_use_id: "tool-use-001",
              content: "file contents here",
              is_error: false
            }
          ]
        },
        parent_tool_use_id: nil
      },
      overrides
    )
  end

  # ── Result Messages ──

  def result_message(overrides \\ %{}) do
    Map.merge(
      %ResultMessage{
        type: "result",
        subtype: "success",
        session_id: "session-abc123",
        is_error: false,
        result: "Task completed successfully",
        duration_ms: 15_000,
        num_turns: 5,
        usage: %Usage{input_tokens: 1000, output_tokens: 500}
      },
      overrides
    )
  end

  def error_result_message(error \\ "Session timed out", overrides \\ %{}) do
    Map.merge(
      %ErrorResultMessage{
        type: "result",
        subtype: "error_during_execution",
        session_id: "session-abc123",
        is_error: true,
        error: error,
        duration_ms: 5_000,
        num_turns: 2,
        usage: %Usage{input_tokens: 500, output_tokens: 200}
      },
      overrides
    )
  end
end
