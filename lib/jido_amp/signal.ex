defmodule Jido.Amp.Signal do
  @moduledoc """
  Custom typed signal modules and builders for Amp session events.

  These signals are emitted by the HandleMessage action for downstream
  consumers (parent agents, UI, logging).
  """

  alias __MODULE__.{
    AssistantText,
    Thinking,
    SessionStart,
    SessionCompleted,
    SessionFailed,
    SessionStarted,
    ToolResult,
    ToolUse
  }

  defmodule SessionStart do
    @moduledoc false

    use Jido.Signal,
      type: "amp.session.start",
      default_source: "/amp",
      schema: [
        prompt: [type: :string, required: true, doc: "Initial prompt to execute"],
        options: [type: {:map, :any, :any}, required: false, default: %{}, doc: "Amp options"]
      ]
  end

  defmodule SessionStarted do
    @moduledoc false

    use Jido.Signal,
      type: "amp.session.started",
      default_source: "/amp",
      schema: [
        session_id: [type: :string, required: true, doc: "Amp session identifier"],
        cwd: [type: {:or, [:string, nil]}, required: false, doc: "Current working directory"],
        tools: [type: {:list, :any}, required: false, default: [], doc: "Available tools"]
      ]
  end

  defmodule AssistantText do
    @moduledoc false

    use Jido.Signal,
      type: "amp.turn.text",
      default_source: "/amp",
      schema: [
        session_id: [type: {:or, [:string, nil]}, required: true, doc: "Amp session identifier"],
        text: [type: :string, required: true, doc: "Assistant text chunk"]
      ]
  end

  defmodule Thinking do
    @moduledoc false

    use Jido.Signal,
      type: "amp.turn.thinking",
      default_source: "/amp",
      schema: [
        session_id: [type: {:or, [:string, nil]}, required: true, doc: "Amp session identifier"],
        thinking: [type: :string, required: true, doc: "Model reasoning text chunk"]
      ]
  end

  defmodule ToolUse do
    @moduledoc false

    use Jido.Signal,
      type: "amp.turn.tool_use",
      default_source: "/amp",
      schema: [
        session_id: [type: {:or, [:string, nil]}, required: true, doc: "Amp session identifier"],
        tool: [type: :string, required: true, doc: "Tool name"],
        input: [type: {:map, :any, :any}, required: true, doc: "Tool input payload"]
      ]
  end

  defmodule ToolResult do
    @moduledoc false

    use Jido.Signal,
      type: "amp.turn.tool_result",
      default_source: "/amp",
      schema: [
        session_id: [type: {:or, [:string, nil]}, required: true, doc: "Amp session identifier"],
        *: [type: :any, doc: "Tool result payload fields"]
      ]
  end

  defmodule SessionCompleted do
    @moduledoc false

    use Jido.Signal,
      type: "amp.session.completed",
      default_source: "/amp",
      schema: [
        session_id: [type: :string, required: true, doc: "Amp session identifier"],
        result: [type: :string, required: true, doc: "Final result summary"],
        num_turns: [type: :non_neg_integer, required: true, doc: "Conversation turn count"],
        duration_ms: [type: :non_neg_integer, required: true, doc: "Session duration in ms"]
      ]
  end

  defmodule SessionFailed do
    @moduledoc false

    use Jido.Signal,
      type: "amp.session.error",
      default_source: "/amp",
      schema: [
        session_id: [type: :string, required: true, doc: "Amp session identifier"],
        error: [type: :any, required: true, doc: "Failure details"]
      ]
  end

  @doc "Session start request signal."
  def session_start(prompt, options \\ %{})

  def session_start(prompt, options) when is_binary(prompt) and is_list(options) do
    session_start(prompt, Enum.into(options, %{}))
  end

  def session_start(prompt, options) when is_binary(prompt) and is_map(options) do
    SessionStart.new!(%{prompt: prompt, options: options})
  end

  @doc "Session initialized with tools and working directory."
  def session_started(data) do
    SessionStarted.new!(%{
      session_id: data[:session_id],
      cwd: data[:cwd],
      tools: data[:tools]
    })
  end

  @doc "Assistant produced a text response."
  def assistant_text(session_id, text) do
    AssistantText.new!(%{session_id: session_id, text: text})
  end

  @doc "Assistant produced a thinking response."
  def thinking(session_id, thinking) do
    Thinking.new!(%{session_id: session_id, thinking: thinking})
  end

  @doc "Assistant called a tool."
  def tool_use(session_id, %{name: name, input: input}) do
    ToolUse.new!(%{session_id: session_id, tool: name, input: input})
  end

  @doc "Tool execution completed."
  def tool_result(session_id, data) do
    data
    |> Map.put(:session_id, session_id)
    |> ToolResult.new!()
  end

  @doc "Session completed successfully."
  def session_completed(data) do
    SessionCompleted.new!(%{
      session_id: data[:session_id],
      result: data[:result],
      num_turns: data[:num_turns],
      duration_ms: data[:duration_ms]
    })
  end

  @doc "Session failed with an error."
  def session_failed(session_id, error) do
    SessionFailed.new!(%{session_id: session_id, error: error})
  end
end
