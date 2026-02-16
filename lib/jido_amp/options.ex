defmodule Jido.Amp.Options do
  @moduledoc """
  Normalized `Jido.Amp` runtime options with Zoi validation.

  This wrapper accepts map/keyword input and converts validated values into
  `%AmpSdk.Types.Options{}` for execution.
  """

  alias AmpSdk.Types

  @schema Zoi.struct(
            __MODULE__,
            %{
              cwd: Zoi.string() |> Zoi.nullable() |> Zoi.optional(),
              mode: Zoi.string() |> Zoi.nullable() |> Zoi.optional(),
              dangerously_allow_all: Zoi.boolean() |> Zoi.optional(),
              visibility: Zoi.string() |> Zoi.nullable() |> Zoi.optional(),
              settings_file: Zoi.string() |> Zoi.nullable() |> Zoi.optional(),
              log_level: Zoi.string() |> Zoi.nullable() |> Zoi.optional(),
              log_file: Zoi.string() |> Zoi.nullable() |> Zoi.optional(),
              env: Zoi.map() |> Zoi.optional(),
              continue_thread: Zoi.any() |> Zoi.nullable() |> Zoi.optional(),
              mcp_config: Zoi.any() |> Zoi.nullable() |> Zoi.optional(),
              toolbox: Zoi.string() |> Zoi.nullable() |> Zoi.optional(),
              skills: Zoi.string() |> Zoi.nullable() |> Zoi.optional(),
              permissions: Zoi.any() |> Zoi.nullable() |> Zoi.optional(),
              labels: Zoi.list(Zoi.string()) |> Zoi.nullable() |> Zoi.optional(),
              thinking: Zoi.boolean() |> Zoi.optional(),
              stream_timeout_ms: Zoi.integer() |> Zoi.optional(),
              no_ide: Zoi.boolean() |> Zoi.optional(),
              no_notifications: Zoi.boolean() |> Zoi.optional(),
              no_color: Zoi.boolean() |> Zoi.optional(),
              no_jetbrains: Zoi.boolean() |> Zoi.optional()
            },
            coerce: true
          )

  @type t :: unquote(Zoi.type_spec(@schema))

  @enforce_keys Zoi.Struct.enforce_keys(@schema)
  defstruct Zoi.Struct.struct_fields(@schema)

  @doc "Returns the Zoi schema for options."
  @spec schema() :: Zoi.schema()
  def schema, do: @schema

  @doc """
  Validates options from a map, keyword list, or `%Jido.Amp.Options{}`.
  """
  @spec new(keyword() | map() | t()) :: {:ok, t()} | {:error, term()}
  def new(%__MODULE__{} = options), do: {:ok, options}
  def new(options) when is_list(options), do: options |> Enum.into(%{}) |> new()
  def new(options) when is_map(options), do: Zoi.parse(@schema, options)

  @doc "Like `new/1` but raises on validation errors."
  @spec new!(keyword() | map() | t()) :: t()
  def new!(options) do
    case new(options) do
      {:ok, parsed} -> parsed
      {:error, reason} -> raise ArgumentError, "Invalid Jido.Amp options: #{inspect(reason)}"
    end
  end

  @doc """
  Converts options into `%AmpSdk.Types.Options{}`.
  """
  @spec to_amp_options(keyword() | map() | t()) :: {:ok, Types.Options.t()} | {:error, term()}
  def to_amp_options(options) do
    with {:ok, parsed} <- new(options) do
      {:ok, do_to_amp_options(parsed)}
    end
  end

  @doc "Like `to_amp_options/1` but raises on validation errors."
  @spec to_amp_options!(keyword() | map() | t()) :: Types.Options.t()
  def to_amp_options!(options) do
    case to_amp_options(options) do
      {:ok, parsed} -> parsed
      {:error, reason} -> raise ArgumentError, "Invalid Jido.Amp options: #{inspect(reason)}"
    end
  end

  defp do_to_amp_options(%__MODULE__{} = parsed) do
    defaults = Map.from_struct(%Types.Options{})

    parsed_map =
      parsed
      |> Map.from_struct()
      |> Enum.reject(fn {_key, value} -> is_nil(value) end)
      |> Map.new()

    defaults
    |> Map.merge(parsed_map)
    |> then(&struct(Types.Options, &1))
  end
end
