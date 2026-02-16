defmodule Jido.Amp.MCP do
  @moduledoc """
  Amp MCP server management wrappers.
  """

  @doc "Add an MCP server."
  @spec add(String.t(), String.t() | [String.t()], keyword()) :: {:ok, String.t()} | {:error, term()}
  def add(name, command_or_url, opts \\ []) do
    sdk_module().mcp_add(name, command_or_url, opts)
  end

  @doc "List parsed MCP server definitions."
  @spec list(keyword()) :: {:ok, [AmpSdk.Types.MCPServer.t()]} | {:error, term()}
  def list(opts \\ []) do
    sdk_module().mcp_list(opts)
  end

  @doc "List raw MCP CLI output."
  @spec list_raw(keyword()) :: {:ok, String.t()} | {:error, term()}
  def list_raw(opts \\ []) do
    sdk_module().mcp_list_raw(opts)
  end

  @doc "Remove an MCP server."
  @spec remove(String.t()) :: {:ok, String.t()} | {:error, term()}
  def remove(name) do
    sdk_module().mcp_remove(name)
  end

  @doc "Run MCP doctor."
  @spec doctor() :: {:ok, String.t()} | {:error, term()}
  def doctor do
    sdk_module().mcp_doctor()
  end

  @doc "Approve an MCP server."
  @spec approve(String.t()) :: {:ok, String.t()} | {:error, term()}
  def approve(name) do
    sdk_module().mcp_approve(name)
  end

  @doc "Run MCP OAuth login."
  @spec oauth_login(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def oauth_login(server_name, opts \\ []) do
    sdk_module().mcp_oauth_login(server_name, opts)
  end

  @doc "Run MCP OAuth logout."
  @spec oauth_logout(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def oauth_logout(server_name, opts \\ []) do
    sdk_module().mcp_oauth_logout(server_name, opts)
  end

  @doc "Read MCP OAuth status."
  @spec oauth_status(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def oauth_status(server_name, opts \\ []) do
    sdk_module().mcp_oauth_status(server_name, opts)
  end

  defp sdk_module do
    Application.get_env(:jido_amp, :amp_sdk_module, AmpSdk)
  end
end
