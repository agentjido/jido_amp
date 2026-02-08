defmodule Jido.Amp do
  @moduledoc """
  Amplified AI orchestration for the Jido ecosystem.

  Jido.Amp provides tools and agents for orchestrating complex AI workflows using
  the Amp coding agent SDK. It integrates with the broader Jido ecosystem for
  structured agent execution, action handling, and signal management.

  ## Features

  - **Amp SDK Integration** - Define and execute orchestration workflows
  - **Tool Orchestration** - Manage tool definitions and execution context
  - **Error Handling** - Structured error composition with Splode
  - **Schema Validation** - Zoi-based validation for all data structures

  ## Main Components

  - `Jido.Amp.Orchestrator` - Core tool execution engine
  - `Jido.Amp.Tool` - Tool definition and management
  - `Jido.Amp.Error` - Structured error handling
  - `Jido.Amp.Application` - Supervisor and application lifecycle

  ## Quick Start

      # Define a tool specification
      tool_spec = %{
        name: "my_tool",
        description: "Does something useful",
        input_schema: %{
          "type" => "object",
          "properties" => %{
            "param" => %{"type" => "string", "description" => "Input parameter"}
          },
          "required" => ["param"]
        }
      }

      # Execute the tool with the orchestrator
      {:ok, result} = Jido.Amp.Orchestrator.execute(tool_spec, %{"param" => "value"})

  ## Integration with Amp SDK

  The Amp SDK provides the foundation for defining and executing agent-driven
  tasks. Jido.Amp builds on this by providing:

  1. Tool specification and validation (via Zoi schemas)
  2. Error handling and classification (via Splode)
  3. Context and state management for complex orchestrations
  4. Integration with Jido ecosystem patterns

  See the individual module documentation for detailed usage patterns.
  """

  @version "0.1.0"

  @doc """
  Returns the version of Jido.Amp.
  """
  @spec version() :: String.t()
  def version, do: @version
end
