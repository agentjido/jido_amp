defmodule Jido.Amp.Adapter do
  @moduledoc """
  `Jido.Harness.Adapter` implementation for Amp CLI.
  """

  @behaviour Jido.Harness.Adapter

  alias Jido.Amp.{Compatibility, Error, Mapper, Options}
  alias Jido.Harness.{Capabilities, Event, RunRequest, RuntimeContract}

  @request_keys [
    :cwd,
    :mode,
    :dangerously_allow_all,
    :visibility,
    :settings_file,
    :log_level,
    :log_file,
    :env,
    :continue_thread,
    :mcp_config,
    :toolbox,
    :skills,
    :permissions,
    :labels,
    :thinking,
    :stream_timeout_ms,
    :no_ide,
    :no_notifications,
    :no_color,
    :no_jetbrains
  ]
  @request_key_strings Enum.map(@request_keys, &Atom.to_string/1)

  @impl true
  @spec id() :: atom()
  def id, do: :amp

  @impl true
  @spec capabilities() :: map()
  def capabilities do
    %Capabilities{
      streaming?: true,
      tool_calls?: true,
      tool_results?: true,
      thinking?: true,
      cancellation?: false
    }
  end

  @impl true
  @spec run(RunRequest.t(), keyword()) :: {:ok, Enumerable.t()} | {:error, term()}
  def run(%RunRequest{} = request, opts \\ []) when is_list(opts) do
    compat_opts = compatibility_opts(request, opts)

    with :ok <- compatibility_module().check(compat_opts),
         {:ok, amp_options} <- build_amp_options(request, opts) do
      stream =
        sdk_module()
        |> apply(:execute, [request.prompt, amp_options])
        |> Stream.flat_map(fn message ->
          case mapper_module().map_event(message) do
            {:ok, events} when is_list(events) ->
              events

            {:error, reason} ->
              [mapper_error_event(reason)]
          end
        end)

      {:ok, stream}
    else
      {:error, _} = error ->
        error
    end
  rescue
    e in [ArgumentError] ->
      {:error, Error.validation_error("Invalid amp run request", %{details: Exception.message(e)})}
  end

  @impl true
  @spec runtime_contract() :: RuntimeContract.t()
  def runtime_contract do
    RuntimeContract.new!(%{
      provider: :amp,
      host_env_required_any: ["AMP_API_KEY"],
      host_env_required_all: [],
      sprite_env_forward: ["AMP_API_KEY", "AMP_URL", "GH_TOKEN", "GITHUB_TOKEN"],
      sprite_env_injected: %{
        "GH_PROMPT_DISABLED" => "1",
        "GIT_TERMINAL_PROMPT" => "0"
      },
      runtime_tools_required: ["amp"],
      compatibility_probes: [
        %{
          "name" => "amp_help_stream_json",
          "command" => "amp --help",
          "expect_all" => ["--execute", "--stream-json"]
        }
      ],
      install_steps: [
        %{
          "tool" => "amp",
          "when_missing" => true,
          "command" =>
            "if command -v npm >/dev/null 2>&1; then npm install -g @sourcegraph/amp; else echo 'npm not available'; exit 1; fi"
        }
      ],
      auth_bootstrap_steps: [],
      triage_command_template:
        "if command -v timeout >/dev/null 2>&1; then timeout 180 amp -x --stream-json --dangerously-allow-all --no-color < {{prompt_file}}; else amp -x --stream-json --dangerously-allow-all --no-color < {{prompt_file}}; fi",
      coding_command_template:
        "if command -v timeout >/dev/null 2>&1; then timeout 180 amp -x --stream-json --dangerously-allow-all --no-color < {{prompt_file}}; else amp -x --stream-json --dangerously-allow-all --no-color < {{prompt_file}}; fi",
      success_markers: [
        %{"type" => "result", "is_error_false" => true}
      ]
    })
  end

  defp build_amp_options(%RunRequest{} = request, opts) do
    request_opts =
      request
      |> request_option_map()
      |> Map.merge(metadata_opts(request.metadata))

    runtime_opts =
      opts
      |> Keyword.take(@request_keys)
      |> Enum.into(%{})

    merged =
      request_opts
      |> Map.merge(runtime_opts)
      |> maybe_put(:cwd, request.cwd)
      |> maybe_put(:stream_timeout_ms, request.timeout_ms)

    options_module().to_amp_options(merged)
  end

  defp request_option_map(%RunRequest{} = request) do
    %{
      cwd: request.cwd,
      stream_timeout_ms: request.timeout_ms
    }
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Enum.into(%{})
  end

  defp metadata_opts(metadata) when is_map(metadata) do
    metadata
    |> Map.get("amp", Map.get(metadata, :amp, %{}))
    |> normalize_map_keys()
  end

  defp metadata_opts(_), do: %{}

  defp normalize_map_keys(map) when is_map(map) do
    Enum.reduce(map, %{}, fn
      {key, value}, acc when is_atom(key) ->
        Map.put(acc, key, value)

      {key, value}, acc when is_binary(key) ->
        if key in @request_key_strings do
          Map.put(acc, String.to_existing_atom(key), value)
        else
          acc
        end

      _, acc ->
        acc
    end)
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp compatibility_opts(request, opts) do
    metadata = if is_map(request.metadata), do: request.metadata, else: %{}
    metadata_amp = Map.get(metadata, "amp", Map.get(metadata, :amp, %{}))

    case map_get(metadata_amp, :amp_cli_path) || Keyword.get(opts, :amp_cli_path) || Keyword.get(opts, :cli_path) do
      path when is_binary(path) and path != "" -> [amp_cli_path: path]
      _ -> []
    end
  end

  defp mapper_error_event(reason) do
    Event.new!(%{
      type: :session_failed,
      provider: :amp,
      session_id: nil,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      payload: %{"error" => inspect(reason)},
      raw: reason
    })
  end

  defp map_get(map, key) when is_map(map) and is_atom(key) do
    Map.get(map, key, Map.get(map, Atom.to_string(key)))
  end

  defp compatibility_module do
    Application.get_env(:jido_amp, :compatibility_module, Compatibility)
  end

  defp mapper_module do
    Application.get_env(:jido_amp, :mapper_module, Mapper)
  end

  defp options_module do
    Application.get_env(:jido_amp, :options_module, Options)
  end

  defp sdk_module do
    Application.get_env(:jido_amp, :amp_sdk_module, AmpSdk)
  end
end
