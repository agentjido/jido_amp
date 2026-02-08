# Jido.Amp

Amplified AI orchestration for the Jido ecosystem. Provides tools and agents for orchestrating complex AI workflows using the Amp coding agent SDK.

## Features

- **Amp SDK Integration** - Define and execute orchestration workflows with the Amp agent framework
- **Tool Orchestration** - Manage tool definitions, execution, and context
- **Error Handling** - Structured error composition with Splode
- **Schema Validation** - Zoi-based validation for all data structures
- **Ecosystem Integration** - Built for the Jido ecosystem alongside jido, jido_action, jido_signal, and more

## Installation

Add to your `mix.exs`:

```elixir
def deps do
  [
    {:jido_amp, "~> 0.1.0"}
  ]
end
```

Then run:

```bash
mix deps.get
```

## Quick Start

```elixir
# Define a tool
tool = %{
  name: "my_tool",
  description: "Does something useful",
  input_schema: %{
    "type" => "object",
    "properties" => %{
      "param" => %{"type" => "string"}
    }
  }
}

# Execute with Amp orchestrator
{:ok, result} = Jido.Amp.Orchestrator.execute(tool, %{"param" => "value"})
```

## Documentation

- [API Documentation](https://hexdocs.pm/jido_amp)
- [Getting Started Guide](guides/getting-started.md)
- [Contributing](CONTRIBUTING.md)

## Architecture

```
Jido.Amp
├── Orchestrator      # Core tool execution engine
├── Tool              # Tool definition and management
├── Error             # Error handling (Splode-based)
└── Application       # Supervisor and startup
```

## Development

```bash
# Setup
mix setup

# Tests
mix test              # Run tests
mix test --cover      # With coverage report

# Quality checks
mix quality           # All checks: format, credo, dialyzer, doctor
mix docs              # Generate documentation
```

## Project Status

🧪 **Experimental** - This is an early-stage project spiking integration with the Amp SDK. APIs may change as we refine the orchestration patterns.

## License

Apache License 2.0

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines and workflow.

## Related Projects

- [Amp SDK](https://github.com/nshkrdotcom/amp_sdk) - Coding agent framework
- [Jido](https://github.com/agentjido/jido) - Agent execution framework
- [Jido Action](https://github.com/agentjido/jido_action) - Action definitions
- [Jido Signal](https://github.com/agentjido/jido_signal) - Signal handling
