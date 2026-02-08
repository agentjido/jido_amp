# Jido.Amp Usage Rules for LLMs

This file documents rules and patterns for AI coding assistants (Claude, Cursor, etc.) working on Jido.Amp.

## Core Rules

### 1. Error Handling
- **Always** use `Jido.Amp.Error` module for errors
- Error types: `:invalid`, `:execution`, `:config`, `:internal`
- Return `{:error, reason}` from functions, raise exceptions only for programmer errors
- Use error helper functions: `validation_error/2`, `execution_error/2`, etc.

### 2. Schema & Validation
- **Always** define Zoi schemas for core data structures
- Put validation in the schema, not in functions
- Use `Zoi.struct/3` with explicit field definitions
- Provide `new/1` and `new!/1` functions on all structs
- Never manually validate data in function bodies

Example:
```elixir
defmodule Jido.Amp.Tool do
  @schema Zoi.struct(
    __MODULE__,
    %{
      name: Zoi.string(),
      description: Zoi.string() |> Zoi.nullish(),
      input_schema: Zoi.map()
    },
    coerce: true
  )

  @type t :: unquote(Zoi.type_spec(@schema))

  @enforce_keys Zoi.Struct.enforce_keys(@schema)
  defstruct Zoi.Struct.struct_fields(@schema)

  def schema, do: @schema

  def new(attrs), do: Zoi.parse(@schema, attrs)
  def new!(attrs) do
    case new(attrs) do
      {:ok, value} -> value
      {:error, reason} -> raise ArgumentError, "Invalid tool: #{inspect(reason)}"
    end
  end
end
```

### 3. Documentation
- **Every** module needs `@moduledoc` describing its purpose
- **Every** public function needs `@doc` with examples and `@spec`
- Use `iex>` examples in docstrings (tested with doctest)
- Private functions use `@doc false`

### 4. Testing
- Test coverage **must be >90%**
- Tests mirror the module structure under `test/`
- Use descriptive test names: `test "validates required fields"`
- Test both success and error cases
- Run `mix test --cover` before committing

### 5. Code Style
- Use `Logger` for output, never `IO.puts`
- Return tuples for operations: `{:ok, result}` or `{:error, reason}`
- Handle all error cases explicitly
- No bare `raise` unless documenting a programmer error
- Follow Elixir naming conventions (snake_case for functions)

### 6. Dependencies
- **No `jido_dep/4` helpers** in mix.exs
- Use direct Hex versions for published packages
- Use `github: "org/repo", branch: "main"` for unpublished deps
- Pin versions appropriately (see mix.exs for examples)

### 7. Amp SDK Integration
- Tools are defined as Amp SDK tool specs
- Tool handlers return `{:ok, result}` or `{:error, reason}`
- Use Jido.Amp.Orchestrator to manage tool execution
- Document tool inputs/outputs in module docs

### 8. Git Commits
- Use conventional commit format: `type(scope): description`
- Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `ci`
- Example: `feat(orchestrator): add tool execution pipeline`
- **Never add "ampcode" as author or Co-authored-by**

### 9. Module Organization
- Group related functionality together
- Use submodules for complex features
- Keep modules focused and testable
- Max ~300 lines per module; split if larger

### 10. Quality Checks
Before pushing:
```bash
mix quality    # Runs: format, credo, dialyzer, doctor
mix test       # Run with coverage
mix docs       # Generate docs
```

All must pass with no warnings or errors.

## Common Patterns

### Handling Configuration
```elixir
def get_config(key, default \\ nil) do
  case Application.get_env(:jido_amp, key) do
    nil -> default
    value -> value
  end
end
```

### Graceful Error Handling
```elixir
def execute(input) do
  with {:ok, validated} <- Input.new(input),
       {:ok, result} <- do_work(validated),
       {:ok, formatted} <- format_result(result) do
    {:ok, formatted}
  else
    {:error, reason} -> {:error, Jido.Amp.Error.execution_error("Failed", %{reason: reason})}
  end
end
```

### Amp Tool Definition
```elixir
def tool_spec do
  %{
    name: "my_tool",
    description: "What this tool does",
    input_schema: %{
      "type" => "object",
      "properties" => %{
        "param" => %{"type" => "string", "description" => "..."}
      },
      "required" => ["param"]
    }
  }
end
```

## File Templates

### New Module
```elixir
defmodule Jido.Amp.MyModule do
  @moduledoc """
  Brief description of this module.

  ## Overview
  More detailed explanation of what this does and why.

  ## Examples

      iex> Jido.Amp.MyModule.do_thing(:input)
      {:ok, :result}
  """

  require Logger

  # Schema definitions here if needed

  @doc """
  Does something specific.

  ## Parameters
    * `input` - Description
    * `opts` - Keyword options
      * `:timeout` - Timeout in ms (default: 5000)

  ## Returns
    * `{:ok, result}` on success
    * `{:error, reason}` on failure
  """
  @spec do_thing(term(), keyword()) :: {:ok, term()} | {:error, term()}
  def do_thing(input, opts \\ []) do
    # Implementation
  end
end
```

### New Test
```elixir
defmodule Jido.Amp.MyModuleTest do
  use ExUnit.Case, async: true
  doctest Jido.Amp.MyModule

  describe "do_thing/2" do
    test "handles valid input" do
      {:ok, result} = Jido.Amp.MyModule.do_thing(:input)
      assert result == :expected
    end

    test "returns error for invalid input" do
      {:error, _reason} = Jido.Amp.MyModule.do_thing(nil)
    end
  end
end
```

## Questions?

Refer to:
- `AGENTS.md` for project guidelines
- `GENERIC_PACKAGE_QA.md` for ecosystem standards
- Existing modules under `lib/jido_amp/` for patterns
