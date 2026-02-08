defmodule Jido.Amp.Test.Fixtures do
  @moduledoc """
  Test fixtures and helpers for Jido.Amp tests.
  """

  def valid_tool_spec do
    %{
      "name" => "test_tool",
      "description" => "A test tool",
      "input_schema" => %{
        "type" => "object",
        "properties" => %{
          "param" => %{"type" => "string", "description" => "A parameter"}
        },
        "required" => ["param"]
      }
    }
  end

  def simple_tool_spec do
    %{
      "name" => "simple",
      "description" => "Simple tool",
      "input_schema" => %{}
    }
  end

  def echo_tool_spec do
    %{
      "name" => "echo",
      "description" => "Echo input",
      "input_schema" => %{
        "type" => "object",
        "properties" => %{
          "message" => %{"type" => "string"}
        }
      }
    }
  end
end
