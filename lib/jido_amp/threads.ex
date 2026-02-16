defmodule Jido.Amp.Threads do
  @moduledoc """
  Thread lifecycle and management operations for Amp.

  This module mirrors all thread-related operations from `AmpSdk`.
  """

  @doc "Create a new thread."
  @spec new(keyword()) :: {:ok, String.t()} | {:error, term()}
  def new(opts \\ []) do
    sdk_module().threads_new(opts)
  end

  @doc "List threads as typed summaries."
  @spec list(keyword()) :: {:ok, [AmpSdk.Types.ThreadSummary.t()]} | {:error, term()}
  def list(opts \\ []) do
    sdk_module().threads_list(opts)
  end

  @doc "List threads as raw CLI output."
  @spec list_raw(keyword()) :: {:ok, String.t()} | {:error, term()}
  def list_raw(opts \\ []) do
    sdk_module().threads_list_raw(opts)
  end

  @doc "Search threads."
  @spec search(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def search(query, opts \\ []) do
    sdk_module().threads_search(query, opts)
  end

  @doc "Render a thread as markdown."
  @spec markdown(String.t()) :: {:ok, String.t()} | {:error, term()}
  def markdown(thread_id) do
    sdk_module().threads_markdown(thread_id)
  end

  @doc "Share a thread."
  @spec share(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def share(thread_id, opts \\ []) do
    sdk_module().threads_share(thread_id, opts)
  end

  @doc "Rename a thread."
  @spec rename(String.t(), String.t()) :: {:ok, String.t()} | {:error, term()}
  def rename(thread_id, name) do
    sdk_module().threads_rename(thread_id, name)
  end

  @doc "Archive a thread."
  @spec archive(String.t()) :: {:ok, String.t()} | {:error, term()}
  def archive(thread_id) do
    sdk_module().threads_archive(thread_id)
  end

  @doc "Delete a thread."
  @spec delete(String.t()) :: {:ok, String.t()} | {:error, term()}
  def delete(thread_id) do
    sdk_module().threads_delete(thread_id)
  end

  @doc "Run handoff for a thread."
  @spec handoff(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def handoff(thread_id, opts \\ []) do
    sdk_module().threads_handoff(thread_id, opts)
  end

  @doc "Replay a thread."
  @spec replay(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def replay(thread_id, opts \\ []) do
    sdk_module().threads_replay(thread_id, opts)
  end

  defp sdk_module do
    Application.get_env(:jido_amp, :amp_sdk_module, AmpSdk)
  end
end
