defmodule Jido.Amp do
  @moduledoc """
  Amp CLI agent integration for the Jido ecosystem.

  This package provides:

  - `run/2` and `execute/2` convenience wrappers around Amp SDK execution
  - A Jido agent runtime (`Jido.Amp.Agent`) that streams SDK messages as signals
  - Curated top-level read operations (threads/tools/usage)
  - Full management API via namespaced modules (`Jido.Amp.Threads`, etc.)
  - Mix tasks for install and thread execution workflows

  ## Streaming Compatibility

  `run/2` and `execute/2` require Amp CLI support for
  `--execute --stream-json` (required by `amp_sdk` streaming mode).
  Use `Jido.Amp.compatible?/0` or `mix amp.compat` to verify the current host.

  ## Quick Start

      # Compatibility check for streaming execution
      :ok = Jido.Amp.assert_compatible!()

      # Blocking execution
      {:ok, result} = Jido.Amp.run("Fix the failing test", cwd: "/my/project")

      # Curated management operation
      {:ok, threads} = Jido.Amp.threads_list()

  """

  @version "0.1.0"
  alias Jido.Amp.{CLI, Compatibility, Installer, MCP, Options, Permissions, Threads, Tools}

  @doc "Returns the package version."
  @spec version() :: String.t()
  def version, do: @version

  @doc """
  Returns true if the Amp CLI binary can be found.

  Accepts `:amp_cli_path` (or `:cli_path`) to override CLI resolution.
  """
  @spec cli_installed?(keyword()) :: boolean()
  def cli_installed?(opts \\ []) when is_list(opts) do
    match?({:ok, _}, CLI.resolve(opts))
  end

  @doc """
  Returns `true` if the local Amp CLI supports required streaming flags.

  Accepts `:amp_cli_path` (or `:cli_path`) to override CLI resolution.
  """
  @spec compatible?(keyword()) :: boolean()
  def compatible?(opts \\ []) when is_list(opts) do
    Compatibility.compatible?(opts)
  end

  @doc """
  Raises `Jido.Amp.Error.ConfigError` if the local Amp CLI is incompatible.

  Accepts `:amp_cli_path` (or `:cli_path`) to override CLI resolution.
  """
  @spec assert_compatible!(keyword()) :: :ok | no_return()
  def assert_compatible!(opts \\ []) when is_list(opts) do
    Compatibility.assert_compatible!(opts)
  end

  @doc """
  Ensures Amp CLI is installed at a deterministic location.

  Accepts:
  - `:amp_cli_path` / `:cli_path` (exact target executable path)
  - `:install_path` (exact target executable path)
  - `:install_prefix` (npm prefix directory, binary expected under `<prefix>/bin/amp`)
  - `:force` (reinstall even when already present)
  """
  @spec ensure_cli_installed(keyword()) :: {:ok, map()} | {:error, term()}
  def ensure_cli_installed(opts \\ []) when is_list(opts) do
    Installer.ensure_installed(opts)
  end

  @doc """
  Stream SDK messages for a prompt.

  Raises `Jido.Amp.Error.ConfigError` when compatibility checks fail.

  Supports `:amp_cli_path` / `:cli_path` as deterministic CLI override.
  """
  @spec execute(String.t(), keyword()) :: Enumerable.t(AmpSdk.Types.stream_message())
  def execute(prompt, opts \\ []) when is_binary(prompt) do
    {compat_opts, amp_opts} = split_cli_override_opts(opts)

    assert_compatible!(compat_opts)

    CLI.with_amp_cli_path(compat_opts[:amp_cli_path], fn ->
      sdk_module().execute(prompt, Options.to_amp_options!(amp_opts))
    end)
  end

  @doc """
  Run a prompt through Amp and return the result.

  Returns `{:error, %Jido.Amp.Error.ConfigError{}}` if compatibility checks fail.

  ## Options

  Accepts all fields from `AmpSdk.Types.Options`.
  Also supports `:amp_cli_path` / `:cli_path` as deterministic CLI override.

  """
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

  @doc "Create a typed user message for JSON-input streaming."
  @spec create_user_message(String.t()) :: AmpSdk.Types.UserInputMessage.t()
  def create_user_message(text) do
    sdk_module().create_user_message(text)
  end

  @doc "Create a typed permission struct."
  @spec create_permission(String.t(), String.t(), keyword()) :: AmpSdk.Types.Permission.t()
  def create_permission(tool, action, opts \\ []) do
    sdk_module().create_permission(tool, action, opts)
  end

  @doc "List known Amp threads (curated top-level API)."
  @spec threads_list(keyword()) :: {:ok, [AmpSdk.Types.ThreadSummary.t()]} | {:error, term()}
  defdelegate threads_list(opts \\ []), to: Threads, as: :list

  @doc "Search Amp threads (curated top-level API)."
  @spec threads_search(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  defdelegate threads_search(query, opts \\ []), to: Threads, as: :search

  @doc "Render a thread as markdown (curated top-level API)."
  @spec threads_markdown(String.t()) :: {:ok, String.t()} | {:error, term()}
  defdelegate threads_markdown(thread_id), to: Threads, as: :markdown

  @doc "Show usage and credit balance."
  @spec usage() :: {:ok, String.t()} | {:error, term()}
  def usage do
    sdk_module().usage()
  end

  @doc "List available Amp tools (curated top-level API)."
  @spec tools_list() :: {:ok, String.t()} | {:error, term()}
  defdelegate tools_list(), to: Tools, as: :list

  @doc "List permission rules (curated top-level API)."
  @spec permissions_list(keyword()) :: {:ok, [AmpSdk.Types.PermissionRule.t()]} | {:error, term()}
  defdelegate permissions_list(opts \\ []), to: Permissions, as: :list

  @doc "List configured MCP servers (curated top-level API)."
  @spec mcp_list(keyword()) :: {:ok, [AmpSdk.Types.MCPServer.t()]} | {:error, term()}
  defdelegate mcp_list(opts \\ []), to: MCP, as: :list

  defp sdk_module do
    Application.get_env(:jido_amp, :amp_sdk_module, AmpSdk)
  end

  defp split_cli_override_opts(opts) do
    cli_path = opts[:amp_cli_path] || opts[:cli_path] || Application.get_env(:jido_amp, :amp_cli_path)
    compat_opts = if is_binary(cli_path) and cli_path != "", do: [amp_cli_path: cli_path], else: []
    {compat_opts, Keyword.drop(opts, [:amp_cli_path, :cli_path])}
  end
end
