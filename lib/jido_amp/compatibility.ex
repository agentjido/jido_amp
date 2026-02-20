defmodule Jido.Amp.Compatibility do
  @moduledoc """
  Runtime compatibility checks for the local Amp CLI and `amp_sdk` streaming mode.

  `Jido.Amp.run/2` and `Jido.Amp.execute/2` require Amp CLI support for
  `--execute --stream-json`. This module verifies that capability and returns
  actionable configuration errors when the environment is incompatible.
  """

  alias Jido.Amp.CLI
  alias Jido.Amp.Error
  alias Jido.Amp.Error.ConfigError

  @required_help_flags ["--execute", "--stream-json"]
  @command_timeout 5_000

  @doc """
  Returns compatibility status with metadata.
  """
  @spec status(keyword()) :: {:ok, map()} | {:error, ConfigError.t()}
  def status(opts \\ []) when is_list(opts) do
    cli_path = CLI.configured_path(opts)

    with {:ok, spec} <- resolve_cli(cli_path),
         {:ok, help_output} <- read_help(spec, cli_path),
         :ok <- ensure_stream_json_support(help_output) do
      {:ok,
       %{
         program: spec.program,
         version: read_version(spec, cli_path),
         required_flags: @required_help_flags,
         amp_cli_path: cli_path
       }}
    end
  end

  @doc """
  Returns `:ok` if compatible, `{:error, config_error}` otherwise.
  """
  @spec check(keyword()) :: :ok | {:error, ConfigError.t()}
  def check(opts \\ []) when is_list(opts) do
    case status(opts) do
      {:ok, _metadata} -> :ok
      {:error, error} -> {:error, error}
    end
  end

  @doc "Returns true when the current Amp CLI is compatible with streaming mode."
  @spec compatible?(keyword()) :: boolean()
  def compatible?(opts \\ []) when is_list(opts) do
    match?({:ok, _}, status(opts))
  end

  @doc """
  Ensures compatibility, raising `Jido.Amp.Error.ConfigError` on failure.
  """
  @spec assert_compatible!(keyword()) :: :ok | no_return()
  def assert_compatible!(opts \\ []) when is_list(opts) do
    case check(opts) do
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

  defp resolve_cli(cli_path) do
    case CLI.resolve(if(cli_path, do: [amp_cli_path: cli_path], else: [])) do
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

  defp read_help(spec, cli_path) do
    case run_command(spec, ["--help"], timeout: @command_timeout, cli_path: cli_path) do
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
                 "Re-run `mix amp.install` and `mix amp.compat` after upgrading the CLI."
               ]
             }
           }
         )}
    end
  end

  defp read_version(spec, cli_path) do
    case run_command(spec, ["--version"], timeout: @command_timeout, cli_path: cli_path) do
      {:ok, version} -> String.trim(version)
      {:error, _reason} -> "unknown"
    end
  end

  defp run_command(spec, args, opts) do
    cli_path = opts[:cli_path]
    run_opts = Keyword.drop(opts, [:cli_path])

    cond do
      function_exported?(command_module(), :run, 3) ->
        CLI.with_amp_cli_path(cli_path, fn ->
          command_module().run(spec, args, run_opts)
        end)

      true ->
        CLI.with_amp_cli_path(cli_path, fn ->
          command_module().run(args, run_opts)
        end)
    end
  end
end
