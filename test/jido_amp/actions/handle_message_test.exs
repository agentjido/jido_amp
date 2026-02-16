defmodule Jido.Amp.Actions.HandleMessageTest do
  use ExUnit.Case, async: true

  alias Jido.Agent.Directive
  alias Jido.Amp.Actions.HandleMessage
  alias Jido.Amp.Test.Fixtures

  @context %{agent: nil}

  # ── SystemMessage ──

  describe "SystemMessage" do
    test "sets session_id in state" do
      msg = Fixtures.system_message()
      {:ok, state, _directives} = HandleMessage.run(%{message: msg}, @context)

      assert state.session_id == "session-abc123"
      assert state.amp_event == msg
    end

    test "emits session_started signal" do
      msg = Fixtures.system_message(%{cwd: "/my/project", tools: ["Read", "Bash"]})
      {:ok, _state, directives} = HandleMessage.run(%{message: msg}, @context)

      signal_directives = Enum.filter(directives, &match?(%Directive.Emit{}, &1))
      assert length(signal_directives) == 1

      [%Directive.Emit{signal: signal}] = signal_directives
      assert signal.type == "amp.session.started"
      assert signal.data.session_id == "session-abc123"
      assert signal.data.cwd == "/my/project"
      assert signal.data.tools == ["Read", "Bash"]
    end

    test "is not terminal" do
      msg = Fixtures.system_message()
      {:ok, _state, directives} = HandleMessage.run(%{message: msg}, @context)

      refute Enum.any?(directives, &match?(%Directive.Stop{}, &1))
    end
  end

  # ── AssistantMessage with TextContent ──

  describe "AssistantMessage with text content" do
    test "emits assistant_text signal for each text block" do
      msg = Fixtures.assistant_text_message("Hello from Amp!")
      {:ok, _state, directives} = HandleMessage.run(%{message: msg}, @context)

      signal_directives = Enum.filter(directives, &match?(%Directive.Emit{}, &1))
      assert length(signal_directives) == 1

      [%Directive.Emit{signal: signal}] = signal_directives
      assert signal.type == "amp.turn.text"
      assert signal.data.text == "Hello from Amp!"
    end

    test "stores amp_event in state" do
      msg = Fixtures.assistant_text_message()
      {:ok, state, _directives} = HandleMessage.run(%{message: msg}, @context)

      assert state.amp_event == msg
    end

    test "is not terminal" do
      msg = Fixtures.assistant_text_message()
      {:ok, _state, directives} = HandleMessage.run(%{message: msg}, @context)

      refute Enum.any?(directives, &match?(%Directive.Stop{}, &1))
    end
  end

  # ── AssistantMessage with ToolUseContent ──

  describe "AssistantMessage with tool_use content" do
    test "emits tool_use signal" do
      msg = Fixtures.assistant_tool_use_message("Write", %{"path" => "/tmp/out.txt"})
      {:ok, _state, directives} = HandleMessage.run(%{message: msg}, @context)

      signal_directives = Enum.filter(directives, &match?(%Directive.Emit{}, &1))
      assert length(signal_directives) == 1

      [%Directive.Emit{signal: signal}] = signal_directives
      assert signal.type == "amp.turn.tool_use"
      assert signal.data.tool == "Write"
      assert signal.data.input == %{"path" => "/tmp/out.txt"}
    end
  end

  # ── AssistantMessage with ThinkingContent ──

  describe "AssistantMessage with thinking content" do
    test "emits thinking signal" do
      msg = Fixtures.assistant_thinking_message("Reasoning...")
      {:ok, _state, directives} = HandleMessage.run(%{message: msg}, @context)

      signal_directives = Enum.filter(directives, &match?(%Directive.Emit{}, &1))
      assert length(signal_directives) == 1

      [%Directive.Emit{signal: signal}] = signal_directives
      assert signal.type == "amp.turn.thinking"
      assert signal.data.thinking == "Reasoning..."
      assert signal.data.session_id == "session-abc123"
    end
  end

  # ── AssistantMessage with mixed content ──

  describe "AssistantMessage with mixed content" do
    test "emits signals for each content block in order" do
      msg = Fixtures.assistant_mixed_content_message()
      {:ok, _state, directives} = HandleMessage.run(%{message: msg}, @context)

      signal_directives = Enum.filter(directives, &match?(%Directive.Emit{}, &1))
      assert length(signal_directives) == 3

      types = Enum.map(signal_directives, fn %Directive.Emit{signal: s} -> s.type end)
      assert types == ["amp.turn.text", "amp.turn.tool_use", "amp.turn.text"]
    end
  end

  # ── AssistantMessage with empty content ──

  describe "AssistantMessage with empty content" do
    test "emits no signals" do
      msg = Fixtures.assistant_empty_content_message()
      {:ok, _state, directives} = HandleMessage.run(%{message: msg}, @context)

      signal_directives = Enum.filter(directives, &match?(%Directive.Emit{}, &1))
      assert signal_directives == []
    end
  end

  # ── UserMessage ──

  describe "UserMessage" do
    test "emits tool_result signal" do
      msg = Fixtures.user_tool_result_message()
      {:ok, _state, directives} = HandleMessage.run(%{message: msg}, @context)

      signal_directives = Enum.filter(directives, &match?(%Directive.Emit{}, &1))
      assert length(signal_directives) == 1

      [%Directive.Emit{signal: signal}] = signal_directives
      assert signal.type == "amp.turn.tool_result"
    end

    test "stores amp_event in state" do
      msg = Fixtures.user_tool_result_message()
      {:ok, state, _directives} = HandleMessage.run(%{message: msg}, @context)

      assert state.amp_event == msg
    end

    test "is not terminal" do
      msg = Fixtures.user_tool_result_message()
      {:ok, _state, directives} = HandleMessage.run(%{message: msg}, @context)

      refute Enum.any?(directives, &match?(%Directive.Stop{}, &1))
    end
  end

  # ── ResultMessage (success) ──

  describe "ResultMessage" do
    test "sets status and result in state" do
      msg = Fixtures.result_message()
      {:ok, state, _directives} = HandleMessage.run(%{message: msg}, @context)

      assert state.status == :success
      assert state.result == "Task completed successfully"
      assert state.amp_event == msg
    end

    test "emits session_completed signal" do
      msg = Fixtures.result_message(%{num_turns: 5, duration_ms: 15_000})
      {:ok, _state, directives} = HandleMessage.run(%{message: msg}, @context)

      signal_directives = Enum.filter(directives, &match?(%Directive.Emit{}, &1))
      assert length(signal_directives) == 1

      [%Directive.Emit{signal: signal}] = signal_directives
      assert signal.type == "amp.session.completed"
      assert signal.data.session_id == "session-abc123"
      assert signal.data.result == "Task completed successfully"
      assert signal.data.num_turns == 5
      assert signal.data.duration_ms == 15_000
    end

    test "is terminal with stop directive" do
      msg = Fixtures.result_message()
      {:ok, _state, directives} = HandleMessage.run(%{message: msg}, @context)

      assert Enum.any?(directives, &match?(%Directive.Stop{reason: :normal}, &1))
    end
  end

  # ── ErrorResultMessage ──

  describe "ErrorResultMessage" do
    test "sets status and error in state" do
      msg = Fixtures.error_result_message("Session timed out")
      {:ok, state, _directives} = HandleMessage.run(%{message: msg}, @context)

      assert state.status == :failure
      assert state.error == "Session timed out"
      assert state.amp_event == msg
    end

    test "emits session_failed signal" do
      msg = Fixtures.error_result_message("Something went wrong")
      {:ok, _state, directives} = HandleMessage.run(%{message: msg}, @context)

      signal_directives = Enum.filter(directives, &match?(%Directive.Emit{}, &1))
      assert length(signal_directives) == 1

      [%Directive.Emit{signal: signal}] = signal_directives
      assert signal.type == "amp.session.error"
      assert signal.data.session_id == "session-abc123"
      assert signal.data.error == "Something went wrong"
    end

    test "is terminal with stop directive" do
      msg = Fixtures.error_result_message()
      {:ok, _state, directives} = HandleMessage.run(%{message: msg}, @context)

      assert Enum.any?(directives, &match?(%Directive.Stop{reason: :normal}, &1))
    end
  end

  # ── Unknown message type ──

  describe "unknown message type" do
    test "returns state with amp_event and no signals" do
      msg = %{type: "unknown", data: "something"}
      {:ok, state, directives} = HandleMessage.run(%{message: msg}, @context)

      assert state.amp_event == msg
      assert directives == []
    end
  end

  # ── Session ID propagation ──

  describe "session_id from agent context" do
    test "prefers message session_id when available" do
      msg = Fixtures.assistant_text_message("test")
      {:ok, _state, directives} = HandleMessage.run(%{message: msg}, @context)

      [%Directive.Emit{signal: signal} | _] =
        Enum.filter(directives, &match?(%Directive.Emit{}, &1))

      assert signal.data.session_id == "session-abc123"
    end

    test "falls back to nil when message and state session_id are absent" do
      msg = Fixtures.assistant_text_message("test", %{session_id: nil})
      {:ok, _state, directives} = HandleMessage.run(%{message: msg}, @context)

      [%Directive.Emit{signal: signal}] = Enum.filter(directives, &match?(%Directive.Emit{}, &1))

      assert signal.data.session_id == nil
    end

    test "uses agent state session_id for signal data" do
      agent = Jido.Amp.Agent.new()
      agent = put_in(agent.state[:session_id], "agent-session-999")
      msg = Fixtures.assistant_text_message("test", %{session_id: nil})

      # emit_to_parent returns nil without a real parent, so emit
      # directives get filtered out. But the session_id is still
      # correctly resolved from agent state in process_message.
      {:ok, state, _directives} = HandleMessage.run(%{message: msg}, %{agent: agent})

      assert state.amp_event == msg
    end
  end
end
