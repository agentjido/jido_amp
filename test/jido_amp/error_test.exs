defmodule Jido.Amp.ErrorTest do
  use ExUnit.Case
  doctest Jido.Amp.Error

  describe "validation_error/2" do
    test "creates InvalidInputError with message" do
      error = Jido.Amp.Error.validation_error("Test error", %{field: "name"})
      assert error.message == "Test error"
      assert error.field == "name"
    end

    test "creates error with default details" do
      error = Jido.Amp.Error.validation_error("Missing field")
      assert error.message == "Missing field"
    end
  end

  describe "execution_error/2" do
    test "creates ExecutionFailureError with message and details" do
      error = Jido.Amp.Error.execution_error("Tool failed", %{tool: "my_tool"})
      assert error.message == "Tool failed"
      assert error.details == %{tool: "my_tool"}
    end

    test "creates error with default details" do
      error = Jido.Amp.Error.execution_error("Execution failed")
      assert error.message == "Execution failed"
      assert error.details == %{}
    end
  end

  describe "config_error/2" do
    test "creates ConfigError with message and details" do
      error = Jido.Amp.Error.config_error("Missing key", %{key: "amp_api_key"})
      assert error.message == "Missing key"
      assert error.key == "amp_api_key"
    end

    test "creates error with default details" do
      error = Jido.Amp.Error.config_error("Config missing")
      assert error.message == "Config missing"
    end
  end

  describe "error message/1" do
    test "InvalidInputError message" do
      error = Jido.Amp.Error.validation_error("Invalid input")
      assert Exception.message(error) == "Invalid input"
    end

    test "ExecutionFailureError message" do
      error = Jido.Amp.Error.execution_error("Execution failed")
      assert Exception.message(error) == "Execution failed"
    end

    test "ConfigError message" do
      error = Jido.Amp.Error.config_error("Config failed")
      assert Exception.message(error) == "Config failed"
    end
  end
end
