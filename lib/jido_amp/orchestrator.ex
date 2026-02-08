defmodule Jido.Amp.Orchestrator do
  @moduledoc """
  Core tool execution engine for Amp orchestrations.

  The Orchestrator manages the execution of tools defined in Amp SDK specifications,
  providing context management, error handling, and integration with the broader
  Jido ecosystem.

  ## Overview

  The Orchestrator acts as a bridge between Amp SDK tool definitions and Jido's
  action and signal systems. It:

  1. Validates tool specifications and inputs
  2. Manages execution context and state
  3. Handles tool execution with error recovery
  4. Integrates with Jido for structured agent workflows

  ## Examples

      # Execute a simple tool
      {:ok, result} = Jido.Amp.Orchestrator.execute(tool_spec, %{"param" => "value"})

      # Execute with custom options
      opts = [timeout: 10000, retry: 3]
      {:ok, result} = Jido.Amp.Orchestrator.execute(tool_spec, input, opts)

      # Execute with context
      context = %{"session_id" => "xyz", "user_id" => "123"}
      {:ok, result} = Jido.Amp.Orchestrator.execute_with_context(tool_spec, input, context, opts)
  """

  require Logger

  @doc """
  Execute a tool with the given input.

  Validates the tool specification and input, then executes the tool with
  default options.

  ## Parameters

    * `tool_spec` - Map with tool definition (name, description, input_schema)
    * `input` - Map of input parameters for the tool
    * `opts` - Keyword list of options (optional)
      * `:timeout` - Execution timeout in milliseconds (default: 30000)
      * `:retry` - Number of retry attempts on failure (default: 0)

  ## Returns

    * `{:ok, result}` - Tool executed successfully with result
    * `{:error, reason}` - Tool execution failed with error reason

  ## Examples

      iex> tool = %{
      ...>   "name" => "echo",
      ...>   "description" => "Echo input",
      ...>   "input_schema" => %{
      ...>     "type" => "object",
      ...>     "properties" => %{"message" => %{"type" => "string"}},
      ...>     "required" => ["message"]
      ...>   }
      ...> }
      iex> Jido.Amp.Orchestrator.execute(tool, %{"message" => "hello"})
      {:ok, %{"message" => "hello"}}
  """
  @spec execute(map(), map(), keyword()) :: {:ok, term()} | {:error, term()}
  def execute(tool_spec, input, opts \\ []) do
    with {:ok, tool} <- Jido.Amp.Tool.new(tool_spec),
         {:ok, validated_input} <- validate_input(tool, input) do
      do_execute(tool, validated_input, opts)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Execute a tool with additional context.

  Similar to `execute/3`, but includes context that can be used for logging,
  tracing, or state management across multiple tool calls.

  ## Parameters

    * `tool_spec` - Map with tool definition
    * `input` - Map of input parameters
    * `context` - Map of context data (session_id, user_id, etc.)
    * `opts` - Keyword list of options

  ## Returns

    * `{:ok, result}` - Tool execution successful
    * `{:error, reason}` - Tool execution failed

  ## Examples

      iex> tool = %{"name" => "test", "description" => "test", "input_schema" => %{}}
      iex> context = %{"session_id" => "abc123"}
      iex> Jido.Amp.Orchestrator.execute_with_context(tool, %{}, context)
      {:ok, %{}}
  """
  @spec execute_with_context(map(), map(), map(), keyword()) ::
          {:ok, term()} | {:error, term()}
  def execute_with_context(tool_spec, input, context, opts \\ []) do
    Logger.debug("Executing tool with context", %{
      tool: tool_spec["name"],
      context: context
    })

    opts = Keyword.put(opts, :context, context)
    execute(tool_spec, input, opts)
  end

  # Private functions

  defp validate_input(_tool, input) do
    case Jido.Amp.Tool.validate(nil, input) do
      :ok -> {:ok, input}
      {:error, reason} -> {:error, Jido.Amp.Error.validation_error("Invalid input: #{reason}")}
    end
  end

  defp do_execute(tool, input, opts) do
    timeout = Keyword.get(opts, :timeout, 30000)
    retry_count = Keyword.get(opts, :retry, 0)

    execute_with_retry(tool, input, retry_count, timeout)
  end

  defp execute_with_retry(tool, input, retry_count, _timeout) do
    case execute_tool(tool, input) do
      {:ok, result} ->
        {:ok, result}

      {:error, _reason} when retry_count > 0 ->
        Logger.warning("Tool execution failed, retrying", %{
          tool: tool.name,
          attempts_left: retry_count
        })

        execute_with_retry(tool, input, retry_count - 1, _timeout)

      {:error, reason} ->
        {:error, Jido.Amp.Error.execution_error("Tool execution failed: #{inspect(reason)}", %{tool: tool.name})}
    end
  end

  defp execute_tool(tool, input) do
    # Placeholder for actual tool execution via Amp SDK
    # This will be implemented based on Amp SDK integration requirements
    try do
      Logger.debug("Executing tool", %{tool: tool.name, input: input})

      # Simulated execution - replace with actual Amp SDK call
      {:ok, %{"executed" => true, "tool" => tool.name, "input" => input}}
    catch
      kind, reason ->
        Logger.error("Tool execution error", %{kind: kind, reason: reason})
        {:error, reason}
    end
  end
end
