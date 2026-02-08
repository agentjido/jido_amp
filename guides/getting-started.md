# Getting Started with Jido.Amp

Jido.Amp provides amplified AI orchestration for the Jido ecosystem. This guide walks you through the basics of defining and executing tools.

## Installation

Add Jido.Amp to your `mix.exs`:

```elixir
defp deps do
  [
    {:jido_amp, "~> 0.1.0"}
  ]
end
```

Then run:

```bash
mix deps.get
```

## Basic Usage

### Define a Tool

Tools are defined as maps following the Amp SDK specification:

```elixir
tool = %{
  "name" => "search",
  "description" => "Search for information",
  "input_schema" => %{
    "type" => "object",
    "properties" => %{
      "query" => %{"type" => "string", "description" => "Search query"},
      "limit" => %{"type" => "integer", "description" => "Max results"}
    },
    "required" => ["query"]
  }
}
```

### Execute the Tool

Use the orchestrator to execute:

```elixir
{:ok, result} = Jido.Amp.Orchestrator.execute(tool, %{"query" => "elixir", "limit" => 10})
```

## Working with Tool Structs

For more advanced usage, work directly with the `Jido.Amp.Tool` module:

```elixir
# Create a validated tool struct
{:ok, my_tool} = Jido.Amp.Tool.new(%{
  "name" => "my_tool",
  "description" => "Does something",
  "input_schema" => %{...}
})

# Validate input
:ok = Jido.Amp.Tool.validate(my_tool, %{"param" => "value"})

# Execute via orchestrator
{:ok, result} = Jido.Amp.Orchestrator.execute(my_tool, %{"param" => "value"})
```

## Error Handling

All errors are structured using Splode. Catch specific error types:

```elixir
case Jido.Amp.Orchestrator.execute(tool, input) do
  {:ok, result} ->
    IO.inspect(result)

  {:error, %Jido.Amp.Error.InvalidInputError{} = error} ->
    IO.puts("Invalid input: #{error.message}")

  {:error, %Jido.Amp.Error.ExecutionFailureError{} = error} ->
    IO.puts("Execution failed: #{error.message}")

  {:error, other} ->
    IO.puts("Unexpected error: #{inspect(other)}")
end
```

## Advanced: Execution Context

Include context for complex orchestrations:

```elixir
context = %{
  "session_id" => "abc123",
  "user_id" => "user_456"
}

{:ok, result} = Jido.Amp.Orchestrator.execute_with_context(
  tool,
  %{"param" => "value"},
  context
)
```

## Advanced: Custom Options

Control execution behavior:

```elixir
opts = [
  timeout: 10000,  # 10 second timeout
  retry: 3         # Retry up to 3 times
]

{:ok, result} = Jido.Amp.Orchestrator.execute(tool, input, opts)
```

## Integration with Jido

Jido.Amp is designed to work seamlessly with other Jido ecosystem packages:

- **Jido** - Agent execution framework
- **Jido.Action** - Action definitions and handlers
- **Jido.Signal** - Signal-based communication
- **Jido.AI** - AI-powered capabilities

## Next Steps

- Check out the [API Documentation](https://hexdocs.pm/jido_amp)
- Review [AGENTS.md](../AGENTS.md) for development patterns
- See [CONTRIBUTING.md](../CONTRIBUTING.md) for contributing guidelines

## Examples

### Search Tool

```elixir
defmodule MyApp.Tools.Search do
  def spec do
    %{
      "name" => "search",
      "description" => "Search the web",
      "input_schema" => %{
        "type" => "object",
        "properties" => %{
          "query" => %{"type" => "string"}
        },
        "required" => ["query"]
      }
    }
  end

  def search(query, limit \\ 10) do
    # Implementation here
    {:ok, []}
  end
end

# Usage
tool = MyApp.Tools.Search.spec()
{:ok, results} = Jido.Amp.Orchestrator.execute(tool, %{"query" => "elixir"})
```

### Database Tool

```elixir
defmodule MyApp.Tools.Database do
  def query_spec do
    %{
      "name" => "db_query",
      "description" => "Execute a database query",
      "input_schema" => %{
        "type" => "object",
        "properties" => %{
          "sql" => %{"type" => "string"},
          "params" => %{"type" => "array", "items" => %{"type" => "string"}}
        },
        "required" => ["sql"]
      }
    }
  end
end
```

## Troubleshooting

### InvalidInputError

Input doesn't match the tool's schema. Check the `input_schema` definition and verify your input matches.

### ExecutionFailureError

The tool failed to execute. Check logs and the error details for the specific cause.

### ConfigError

Required configuration is missing. Ensure your environment is properly configured.

## Questions?

See [CONTRIBUTING.md](../CONTRIBUTING.md) or open an issue on GitHub.
