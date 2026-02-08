defmodule Jido.Amp.OrchestratorTest do
  use ExUnit.Case, async: true
  doctest Jido.Amp.Orchestrator

  import Jido.Amp.Test.Fixtures

  describe "execute/3" do
    test "executes tool with valid input" do
      {:ok, result} = Jido.Amp.Orchestrator.execute(valid_tool_spec(), %{"param" => "value"})
      assert is_map(result)
      assert result["executed"] == true
    end

    test "executes simple tool with empty input" do
      {:ok, result} = Jido.Amp.Orchestrator.execute(simple_tool_spec(), %{})
      assert is_map(result)
      assert result["tool"] == "simple"
    end

    test "returns error for invalid tool spec" do
      {:error, _reason} = Jido.Amp.Orchestrator.execute(%{"name" => "test"}, %{})
    end

    test "returns error for invalid input type" do
      {:error, _reason} = Jido.Amp.Orchestrator.execute(valid_tool_spec(), "not a map")
    end

    test "accepts custom timeout option" do
      {:ok, _result} =
        Jido.Amp.Orchestrator.execute(valid_tool_spec(), %{"param" => "value"}, [timeout: 10000])
    end

    test "accepts retry option" do
      {:ok, _result} =
        Jido.Amp.Orchestrator.execute(valid_tool_spec(), %{"param" => "value"}, [retry: 3])
    end
  end

  describe "execute_with_context/4" do
    test "executes tool with context" do
      context = %{"session_id" => "abc123", "user_id" => "user_456"}

      {:ok, result} =
        Jido.Amp.Orchestrator.execute_with_context(
          valid_tool_spec(),
          %{"param" => "value"},
          context
        )

      assert is_map(result)
      assert result["executed"] == true
    end

    test "executes with context and options" do
      context = %{"session_id" => "xyz"}

      {:ok, result} =
        Jido.Amp.Orchestrator.execute_with_context(
          valid_tool_spec(),
          %{"param" => "value"},
          context,
          [timeout: 5000]
        )

      assert is_map(result)
    end

    test "returns error for invalid tool spec" do
      {:error, _reason} =
        Jido.Amp.Orchestrator.execute_with_context(
          %{"name" => "test"},
          %{},
          %{"session_id" => "abc"}
        )
    end

    test "returns error for invalid input" do
      {:error, _reason} =
        Jido.Amp.Orchestrator.execute_with_context(
          valid_tool_spec(),
          "not a map",
          %{"session_id" => "abc"}
        )
    end
  end
end
