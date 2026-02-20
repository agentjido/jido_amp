defmodule Jido.Amp do
  @moduledoc """
  Amp CLI adapter package for `Jido.Harness`.

  Public surface is intentionally focused on adapter execution plus runtime
  diagnostics/install tooling.
  """

  @version "0.1.0"
  alias Jido.Amp.{CLI, Compatibility, Installer, Options}

  @doc "Returns the package version."
  @spec version() :: String.t()
  def version, do: @version

  @doc "Returns true if the Amp CLI binary can be found."
  @spec cli_installed?(keyword()) :: boolean()
  def cli_installed?(opts \\ []) when is_list(opts) do
    match?({:ok, _}, CLI.resolve(opts))
  end

  @doc "Returns `true` when local Amp CLI supports streaming mode."
  @spec compatible?(keyword()) :: boolean()
  def compatible?(opts \\ []) when is_list(opts) do
    Compatibility.compatible?(opts)
  end

  @doc "Raises `Jido.Amp.Error.ConfigError` when CLI is incompatible."
  @spec assert_compatible!(keyword()) :: :ok | no_return()
  def assert_compatible!(opts \\ []) when is_list(opts) do
    Compatibility.assert_compatible!(opts)
  end

  @doc "Ensures Amp CLI is installed at a deterministic location."
  @spec ensure_cli_installed(keyword()) :: {:ok, map()} | {:error, term()}
  def ensure_cli_installed(opts \\ []) when is_list(opts) do
    Installer.ensure_installed(opts)
  end

  @doc "Run a prompt through Amp and return a final result tuple."
  @spec run(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def run(prompt, opts \\ []) when is_binary(prompt) do
    {compat_opts, amp_opts} = split_cli_override_opts(opts)

    with :ok <- Compatibility.check(compat_opts) do
      CLI.with_amp_cli_path(compat_opts[:amp_cli_path], fn ->
        sdk_module().run(prompt, Options.to_amp_options!(amp_opts))
      end)
    end
  rescue
    e in ArgumentError ->
      {:error, e}
  end

  @doc "Stream raw Amp SDK messages for a prompt."
  @spec execute(String.t(), keyword()) :: Enumerable.t(AmpSdk.Types.stream_message())
  def execute(prompt, opts \\ []) when is_binary(prompt) do
    {compat_opts, amp_opts} = split_cli_override_opts(opts)

    assert_compatible!(compat_opts)

    CLI.with_amp_cli_path(compat_opts[:amp_cli_path], fn ->
      sdk_module().execute(prompt, Options.to_amp_options!(amp_opts))
    end)
  end

  defp sdk_module do
    Application.get_env(:jido_amp, :amp_sdk_module, AmpSdk)
  end

  defp split_cli_override_opts(opts) do
    cli_path = opts[:amp_cli_path] || opts[:cli_path] || Application.get_env(:jido_amp, :amp_cli_path)
    compat_opts = if is_binary(cli_path) and cli_path != "", do: [amp_cli_path: cli_path], else: []
    {compat_opts, Keyword.drop(opts, [:amp_cli_path, :cli_path])}
  end
end
