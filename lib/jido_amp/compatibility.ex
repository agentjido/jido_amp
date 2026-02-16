defmodule Jido.Amp.Compatibility do
  @moduledoc """
  Runtime compatibility checks for the local Amp CLI and `amp_sdk` streaming mode.

  `Jido.Amp.run/2` and `Jido.Amp.execute/2` require Amp CLI support for
  `--execute --stream-json`. This module verifies that capability and returns
  actionable configuration errors when the environment is incompatible.
  """

  alias Jido.Amp.Error
  alias Jido.Amp.Error.ConfigError

  @required_help_flags ["--execute", "--stream-json"]
  @command_timeout 5_000

  @doc """
  Returns compatibility status with metadata.
  """
  @spec status() :: {:ok, map()} | {:error, ConfigError.t()}
  def status do
    with {:ok, spec} <- resolve_cli(),
         {:ok, help_output} <- read_help(),
         :ok <- ensure_stream_json_support(help_output) do
      {:ok,
       %{
         program: spec.program,
         version: read_version(),
         required_flags: @required_help_flags
       }}
    end
  end

  @doc """
  Returns `:ok` if compatible, `{:error, config_error}` otherwise.
  """
  @spec check() :: :ok | {:error, ConfigError.t()}
  def check do
    case status() do
      {:ok, _metadata} -> :ok
      {:error, error} -> {:error, error}
    end
  end

  @doc "Returns true when the current Amp CLI is compatible with streaming mode."
  @spec compatible?() :: boolean()
  def compatible? do
    match?({:ok, _}, status())
  end

  @doc """
  Ensures compatibility, raising `Jido.Amp.Error.ConfigError` on failure.
  """
  @spec assert_compatible!() :: :ok | no_return()
  def assert_compatible! do
    case check() do
      :ok -> :ok
      {:error, error} -> raise error
    end
  end

  @doc false
  @spec cli_module() :: module()
  def cli_module do
    Application.get_env(:jido_amp, :amp_cli_module, AmpSdk.CLI)
  end

  @doc false
  @spec command_module() :: module()
  def command_module do
    Application.get_env(:jido_amp, :amp_command_module, AmpSdk.Command)
  end

  defp resolve_cli do
    case cli_module().resolve() do
      {:ok, spec} ->
        {:ok, spec}

      {:error, reason} ->
        {:error,
         Error.config_error(
           "Amp CLI is not available. Install Amp and run `mix amp.install`.",
           %{
             key: :amp_cli,
             details: %{reason: reason}
           }
         )}
    end
  end

  defp read_help do
    case command_module().run(["--help"], timeout: @command_timeout) do
      {:ok, output} ->
        {:ok, output}

      {:error, reason} ->
        {:error,
         Error.config_error(
           "Unable to read Amp CLI help output for compatibility checks.",
           %{
             key: :amp_cli_help,
             details: %{reason: reason}
           }
         )}
    end
  end

  defp ensure_stream_json_support(help_output) do
    missing =
      @required_help_flags
      |> Enum.reject(&String.contains?(help_output, &1))

    case missing do
      [] ->
        :ok

      _ ->
        {:error,
         Error.config_error(
           "Installed Amp CLI is incompatible with amp_sdk streaming mode. Missing required flags in `amp --help`: #{Enum.join(missing, ", ")}.",
           %{
             key: :amp_cli_streaming_compatibility,
             details: %{
               missing_flags: missing,
               remediation: [
                 "Install an Amp CLI version that supports --execute --stream-json.",
                 "Use `mix amp.thread` for direct thread execution while compatibility is unresolved."
               ]
             }
           }
         )}
    end
  end

  defp read_version do
    case command_module().run(["--version"], timeout: @command_timeout) do
      {:ok, version} -> String.trim(version)
      {:error, _reason} -> "unknown"
    end
  end
end
