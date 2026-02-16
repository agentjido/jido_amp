defmodule Jido.Amp.AgentTest do
  use ExUnit.Case, async: true

  alias Jido.Amp.Agent

  describe "signal_routes/1" do
    test "routes start and internal message signals" do
      routes = Agent.signal_routes(%{})

      assert {"amp.session.start", Jido.Amp.Actions.StartSession} in routes
      assert {"amp.internal.message", Jido.Amp.Actions.HandleMessage} in routes
      assert length(routes) == 2
    end
  end

  describe "schema" do
    test "creates agent with default state" do
      agent = Agent.new()

      assert agent.state.status == :idle
      assert agent.state.prompt == nil
      assert agent.state.session_id == nil
      assert agent.state.worker_pid == nil
      assert agent.state.started_at == nil
      assert agent.state.amp_event == nil
      assert agent.state.result == nil
      assert agent.state.error == nil
    end

    test "state fields are present with correct defaults" do
      agent = Agent.new()

      assert Map.has_key?(agent.state, :status)
      assert Map.has_key?(agent.state, :prompt)
      assert Map.has_key?(agent.state, :session_id)
      assert Map.has_key?(agent.state, :worker_pid)
      assert Map.has_key?(agent.state, :started_at)
      assert Map.has_key?(agent.state, :amp_event)
      assert Map.has_key?(agent.state, :result)
      assert Map.has_key?(agent.state, :error)
    end
  end

  describe "metadata" do
    test "has correct name" do
      agent = Agent.new()
      assert agent.name == "amp_session"
    end

    test "has description" do
      agent = Agent.new()
      assert agent.description == "Manages a single Amp CLI agent session"
    end
  end
end
