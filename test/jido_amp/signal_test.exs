defmodule Jido.Amp.SignalTest do
  use ExUnit.Case, async: true

  alias Jido.Amp.Signal

  describe "session_started/1" do
    test "builds signal with correct type and source" do
      signal =
        Signal.session_started(%{
          session_id: "test-123",
          cwd: "/tmp/project",
          tools: ["Read", "Bash"]
        })

      assert signal.type == "amp.session.started"
      assert signal.source == "/amp"
    end

    test "includes session data" do
      signal =
        Signal.session_started(%{
          session_id: "test-123",
          cwd: "/tmp/project",
          tools: ["Read"]
        })

      assert signal.data.session_id == "test-123"
      assert signal.data.cwd == "/tmp/project"
      assert signal.data.tools == ["Read"]
    end
  end

  describe "assistant_text/2" do
    test "builds signal with session_id and text" do
      signal = Signal.assistant_text("test-123", "Hello!")

      assert signal.type == "amp.turn.text"
      assert signal.source == "/amp"
      assert signal.data.session_id == "test-123"
      assert signal.data.text == "Hello!"
    end
  end

  describe "session_start/2" do
    test "builds start signal from keyword options" do
      signal = Signal.session_start("run checks", cwd: "/tmp/project")

      assert signal.type == "amp.session.start"
      assert signal.source == "/amp"
      assert signal.data.prompt == "run checks"
      assert signal.data.options == %{cwd: "/tmp/project"}
    end
  end

  describe "thinking/2" do
    test "builds signal with session_id and thinking text" do
      signal = Signal.thinking("test-123", "Reasoning")

      assert signal.type == "amp.turn.thinking"
      assert signal.source == "/amp"
      assert signal.data.session_id == "test-123"
      assert signal.data.thinking == "Reasoning"
    end
  end

  describe "tool_use/2" do
    test "builds signal with tool name and input" do
      signal = Signal.tool_use("test-123", %{name: "Read", input: %{path: "/tmp/f.txt"}})

      assert signal.type == "amp.turn.tool_use"
      assert signal.source == "/amp"
      assert signal.data.session_id == "test-123"
      assert signal.data.tool == "Read"
      assert signal.data.input == %{path: "/tmp/f.txt"}
    end
  end

  describe "tool_result/2" do
    test "builds signal with session_id and result data" do
      signal = Signal.tool_result("test-123", %{content: "file contents"})

      assert signal.type == "amp.turn.tool_result"
      assert signal.source == "/amp"
      assert signal.data.session_id == "test-123"
      assert signal.data.content == "file contents"
    end
  end

  describe "session_completed/1" do
    test "builds signal with result and metrics" do
      signal =
        Signal.session_completed(%{
          session_id: "test-123",
          result: "All tests pass",
          num_turns: 5,
          duration_ms: 12_000
        })

      assert signal.type == "amp.session.completed"
      assert signal.source == "/amp"
      assert signal.data.session_id == "test-123"
      assert signal.data.result == "All tests pass"
      assert signal.data.num_turns == 5
      assert signal.data.duration_ms == 12_000
    end
  end

  describe "session_failed/2" do
    test "builds signal with session_id and error" do
      signal = Signal.session_failed("test-123", "Connection timeout")

      assert signal.type == "amp.session.error"
      assert signal.source == "/amp"
      assert signal.data.session_id == "test-123"
      assert signal.data.error == "Connection timeout"
    end
  end
end
