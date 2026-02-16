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
  alias Jido.Amp.{Compatibility, MCP, Options, Permissions, Threads, Tools}

  @doc "Returns the package version."
  @spec version() :: String.t()
  def version, do: @version

  @doc "Returns true if the Amp CLI binary can be found."
  @spec cli_installed?() :: boolean()
  def cli_installed? do
    match?({:ok, _}, Compatibility.cli_module().resolve())
  end

  @doc """
  Returns `true` if the local Amp CLI supports required streaming flags.
  """
  @spec compatible?() :: boolean()
  def compatible? do
    Compatibility.compatible?()
  end

  @doc """
  Raises `Jido.Amp.Error.ConfigError` if the local Amp CLI is incompatible.
  """
  @spec assert_compatible!() :: :ok | no_return()
  def assert_compatible! do
    Compatibility.assert_compatible!()
  end

  @doc """
  Stream SDK messages for a prompt.

  Raises `Jido.Amp.Error.ConfigError` when compatibility checks fail.
  """
  @spec execute(String.t(), keyword()) :: Enumerable.t(AmpSdk.Types.stream_message())
  def execute(prompt, opts \\ []) when is_binary(prompt) do
    assert_compatible!()
    sdk_module().execute(prompt, Options.to_amp_options!(opts))
  end

  @doc """
  Run a prompt through Amp and return the result.

  Returns `{:error, %Jido.Amp.Error.ConfigError{}}` if compatibility checks fail.

  ## Options

  Accepts all fields from `AmpSdk.Types.Options`.

  """
  @spec run(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def run(prompt, opts \\ []) when is_binary(prompt) do
    with :ok <- Compatibility.check() do
      sdk_module().run(prompt, Options.to_amp_options!(opts))
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
end
