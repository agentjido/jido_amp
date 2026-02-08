defmodule Jido.Amp.Error do
  @moduledoc """
  Centralized error handling for Jido.Amp using Splode.

  Error classes are for classification; concrete `...Error` structs are for raising/matching.

  ## Error Classes

  - `:invalid` - Invalid input or configuration
  - `:execution` - Runtime execution failures
  - `:config` - Configuration errors
  - `:internal` - Unexpected internal errors

  ## Examples

      iex> Jido.Amp.Error.validation_error("Email is required", %{field: "email"})
      %Jido.Amp.Error.InvalidInputError{message: "Email is required", field: "email"}

      iex> Jido.Amp.Error.execution_error("Tool failed", %{tool: "my_tool"})
      %Jido.Amp.Error.ExecutionFailureError{message: "Tool failed", details: %{tool: "my_tool"}}
  """

  use Splode,
    error_classes: [
      invalid: Invalid,
      execution: Execution,
      config: Config,
      internal: Internal
    ],
    unknown_error: __MODULE__.Internal.UnknownError

  # Error classes – classification only
  defmodule Invalid do
    @moduledoc "Invalid input error class for Splode."
    use Splode.ErrorClass, class: :invalid
  end

  defmodule Execution do
    @moduledoc "Execution error class for Splode."
    use Splode.ErrorClass, class: :execution
  end

  defmodule Config do
    @moduledoc "Configuration error class for Splode."
    use Splode.ErrorClass, class: :config
  end

  defmodule Internal do
    @moduledoc "Internal error class for Splode."
    use Splode.ErrorClass, class: :internal

    defmodule UnknownError do
      @moduledoc false
      defexception [:message, :details]
    end
  end

  # Concrete exception structs – raise/rescue these

  defmodule InvalidInputError do
    @moduledoc """
    Error for invalid input parameters.

    Raised when input validation fails or required fields are missing.
    """
    defexception [:message, :field, :value, :details]

    @impl true
    def message(%__MODULE__{message: msg}), do: msg
  end

  defmodule ExecutionFailureError do
    @moduledoc """
    Error for runtime execution failures.

    Raised when tool execution, orchestration, or other runtime operations fail.
    """
    defexception [:message, :details]

    @impl true
    def message(%__MODULE__{message: msg}), do: msg
  end

  defmodule ConfigError do
    @moduledoc """
    Error for configuration errors.

    Raised when required configuration is missing or invalid.
    """
    defexception [:message, :key, :details]

    @impl true
    def message(%__MODULE__{message: msg}), do: msg
  end

  # Helper functions

  @doc """
  Create a validation error with optional details.

  ## Examples

      iex> Jido.Amp.Error.validation_error("Required field missing", %{field: "name"})
      %Jido.Amp.Error.InvalidInputError{message: "Required field missing", details: %{field: "name"}}
  """
  @spec validation_error(String.t(), map()) :: InvalidInputError.t()
  def validation_error(message, details \\ %{}) do
    InvalidInputError.exception(Keyword.merge([message: message], Map.to_list(details)))
  end

  @doc """
  Create an execution error with optional details.

  ## Examples

      iex> Jido.Amp.Error.execution_error("Tool execution failed", %{tool: "test"})
      %Jido.Amp.Error.ExecutionFailureError{message: "Tool execution failed", details: %{tool: "test"}}
  """
  @spec execution_error(String.t(), map()) :: ExecutionFailureError.t()
  def execution_error(message, details \\ %{}) do
    ExecutionFailureError.exception(message: message, details: details)
  end

  @doc """
  Create a configuration error with optional details.

  ## Examples

      iex> Jido.Amp.Error.config_error("Missing API key", %{key: "amp_api_key"})
      %Jido.Amp.Error.ConfigError{message: "Missing API key", key: "amp_api_key"}
  """
  @spec config_error(String.t(), map()) :: ConfigError.t()
  def config_error(message, details \\ %{}) do
    ConfigError.exception(Keyword.merge([message: message], Map.to_list(details)))
  end
end
