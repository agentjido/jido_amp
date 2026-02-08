defmodule Jido.Amp.Tool do
  @moduledoc """
  Tool definition and validation for Amp orchestrations.

  Defines the structure and validation rules for tool specifications used by
  the orchestrator. Tools follow Amp SDK conventions while adding Jido ecosystem
  support for structured execution.

  ## Tool Specification

  A tool specification is a map with the following required fields:

    * `name` - Unique identifier for the tool (string)
    * `description` - Human-readable description (string)
    * `input_schema` - JSON Schema defining input parameters (map)

  Optional fields:

    * `handler` - Function to execute the tool (optional, defaults to Amp SDK)
    * `timeout` - Execution timeout in milliseconds (optional)
    * `tags` - List of tags for categorization (optional)

  ## Schema Validation

  Input schemas follow JSON Schema format. Example:

  ```elixir
  input_schema = %{
    "type" => "object",
    "properties" => %{
      "query" => %{"type" => "string", "description" => "Search query"},
      "limit" => %{"type" => "integer", "description" => "Result limit"}
    },
    "required" => ["query"]
  }
  ```

  ## Examples

      iex> tool_map = %{
      ...>   "name" => "search",
      ...>   "description" => "Search for something",
      ...>   "input_schema" => %{"type" => "object"}
      ...> }
      iex> {:ok, tool} = Jido.Amp.Tool.new(tool_map)
      iex> tool.name
      "search"

      iex> {:ok, tool} = Jido.Amp.Tool.new(%{"name" => "test", "description" => "test", "input_schema" => %{}})
      iex> Jido.Amp.Tool.validate(tool, %{})
      :ok
  """

  @schema Zoi.struct(
    __MODULE__,
    %{
      name: Zoi.string(),
      description: Zoi.string(),
      input_schema: Zoi.map(),
      handler: Zoi.function() |> Zoi.nullish(),
      timeout: Zoi.integer() |> Zoi.nullish(),
      tags: Zoi.array(Zoi.string()) |> Zoi.default([])
    },
    coerce: true
  )

  @type t :: unquote(Zoi.type_spec(@schema))

  @enforce_keys Zoi.Struct.enforce_keys(@schema)
  defstruct Zoi.Struct.struct_fields(@schema)

  @doc """
  Returns the Zoi schema for Tool struct.
  """
  @spec schema() :: Zoi.schema()
  def schema, do: @schema

  @doc """
  Creates a new Tool from a map, validating with Zoi.

  ## Parameters

    * `attrs` - Map with tool attributes

  ## Returns

    * `{:ok, tool}` - Tool created successfully
    * `{:error, reason}` - Validation failed

  ## Examples

      iex> {:ok, tool} = Jido.Amp.Tool.new(%{"name" => "my_tool", "description" => "A tool", "input_schema" => %{}})
      iex> tool.name
      "my_tool"

      iex> {:error, _reason} = Jido.Amp.Tool.new(%{})
  """
  @spec new(map()) :: {:ok, t()} | {:error, term()}
  def new(attrs) when is_map(attrs) do
    Zoi.parse(@schema, attrs)
  end

  def new(_attrs) do
    {:error, "input must be a map"}
  end

  @doc """
  Like new/1 but raises on validation errors.

  ## Examples

      iex> tool = Jido.Amp.Tool.new!(%{"name" => "tool", "description" => "desc", "input_schema" => %{}})
      iex> tool.name
      "tool"
  """
  @spec new!(map()) :: t()
  def new!(attrs) do
    case new(attrs) do
      {:ok, value} -> value
      {:error, reason} -> raise ArgumentError, "Invalid tool: #{inspect(reason)}"
    end
  end

  @doc """
  Validates input against the tool's input schema.

  Currently performs basic validation that input is a map. Full JSON Schema
  validation can be added as needed.

  ## Parameters

    * `tool` - Tool struct
    * `input` - Input map to validate

  ## Returns

    * `:ok` - Input is valid
    * `{:error, reason}` - Validation failed

  ## Examples

      iex> tool = Jido.Amp.Tool.new!(%{"name" => "test", "description" => "test", "input_schema" => %{}})
      iex> Jido.Amp.Tool.validate(tool, %{})
      :ok

      iex> tool = Jido.Amp.Tool.new!(%{"name" => "test", "description" => "test", "input_schema" => %{}})
      iex> Jido.Amp.Tool.validate(tool, "not a map")
      {:error, "input must be a map"}
  """
  @spec validate(t(), term()) :: :ok | {:error, String.t()}
  def validate(_tool, input) when is_map(input) do
    :ok
  end

  def validate(_tool, _input) do
    {:error, "input must be a map"}
  end

  @doc """
  Merges tool configuration with defaults.

  Useful for setting defaults before execution (e.g., timeout).

  ## Parameters

    * `tool` - Tool struct
    * `defaults` - Map of default values

  ## Returns

    * Updated tool struct

  ## Examples

      iex> tool = Jido.Amp.Tool.new!(%{"name" => "test", "description" => "test", "input_schema" => %{}})
      iex> merged = Jido.Amp.Tool.merge_defaults(tool, %{timeout: 5000})
      iex> merged.timeout
      5000
  """
  @spec merge_defaults(t(), map()) :: t()
  def merge_defaults(tool, defaults) when is_map(defaults) do
    Enum.reduce(defaults, tool, fn {key, value}, acc ->
      case key do
        :name -> acc
        :description -> acc
        :input_schema -> acc
        _ ->
          Map.put(acc, key, value)
      end
    end)
  end
end
