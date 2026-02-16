defmodule Jido.Amp.Actions.StartSessionTest do
  use ExUnit.Case, async: true

  alias Jido.Agent.Directive
  alias Jido.Amp.Actions.StartSession
  alias Jido.Amp.Test.StubStreamRunner

  describe "run/2" do
    test "returns ok tuple with state and directives" do
      params = %{prompt: "Fix the failing test"}
      context = %{agent_pid: self()}

      assert {:ok, state, directives} = StartSession.run(params, context)
      assert is_map(state)
      assert is_list(directives)
    end

    test "sets status to running" do
      {:ok, state, _directives} =
        StartSession.run(%{prompt: "Hello"}, %{agent_pid: self()})

      assert state.status == :running
    end

    test "generates session_id starting with amp-" do
      {:ok, state, _directives} =
        StartSession.run(%{prompt: "Hello"}, %{agent_pid: self()})

      assert String.starts_with?(state.session_id, "amp-")
      assert String.length(state.session_id) > 4
    end

    test "preserves prompt in state" do
      {:ok, state, _directives} =
        StartSession.run(%{prompt: "Refactor the module"}, %{agent_pid: self()})

      assert state.prompt == "Refactor the module"
    end

    test "sets started_at timestamp" do
      {:ok, state, _directives} =
        StartSession.run(%{prompt: "Hello"}, %{agent_pid: self()})

      assert %DateTime{} = state.started_at
    end

    test "includes spawn directive for stream_runner" do
      {:ok, _state, directives} =
        StartSession.run(%{prompt: "Hello"}, %{agent_pid: self()})

      assert [%Directive.Spawn{tag: :stream_runner}] = directives
    end

    test "spawn directive contains Task child spec" do
      {:ok, _state, directives} =
        StartSession.run(%{prompt: "Hello"}, %{agent_pid: self()})

      [%Directive.Spawn{child_spec: {Task, fun}}] = directives
      assert is_function(fun, 0)
    end

    test "uses self() when agent_pid not in context" do
      {:ok, _state, directives} = StartSession.run(%{prompt: "Hello"}, %{})

      [%Directive.Spawn{child_spec: {Task, _fun}}] = directives
    end

    test "passes merged options to stream runner task" do
      params = %{
        prompt: "Hello",
        options: %{mode: "auto", no_color: true},
        mode: "smart",
        cwd: "/tmp/project"
      }

      {:ok, _state, [%Directive.Spawn{child_spec: {Task, fun}}]} =
        StartSession.run(params, %{agent_pid: self(), stream_runner: StubStreamRunner})

      assert :ok = fun.()
      assert_receive {:stub_stream_runner_run, args}
      assert %AmpSdk.Types.Options{} = args.options
      assert args.options.mode == "smart"
      assert args.options.cwd == "/tmp/project"
      assert args.options.no_color == true
    end

    test "defaults cwd when not provided" do
      {:ok, _state, [%Directive.Spawn{child_spec: {Task, fun}}]} =
        StartSession.run(%{prompt: "Hello", options: %{}}, %{
          agent_pid: self(),
          stream_runner: StubStreamRunner
        })

      assert :ok = fun.()
      assert_receive {:stub_stream_runner_run, args}
      assert args.options.cwd == File.cwd!()
    end

    test "generates unique session_ids" do
      {:ok, state1, _} = StartSession.run(%{prompt: "a"}, %{agent_pid: self()})
      {:ok, state2, _} = StartSession.run(%{prompt: "b"}, %{agent_pid: self()})

      refute state1.session_id == state2.session_id
    end
  end
end
