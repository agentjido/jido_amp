defmodule Jido.Amp.Test.StubCLI do
  @moduledoc false

  def resolve do
    Application.get_env(:jido_amp, :stub_cli_resolve, fn -> {:ok, %{program: "/tmp/amp"}} end).()
  end
end

defmodule Jido.Amp.Test.StubCommand do
  @moduledoc false

  def run(args, opts \\ []) do
    Application.get_env(:jido_amp, :stub_command_run, fn _args, _opts -> {:ok, ""} end).(args, opts)
  end

  def run(_spec, args, opts) do
    run(args, opts)
  end
end

defmodule Jido.Amp.Test.StubAmpSdk do
  @moduledoc false

  alias AmpSdk.Types.ResultMessage

  def execute(input, options) do
    Application.get_env(:jido_amp, :stub_amp_sdk_execute, fn _input, _options ->
      [%ResultMessage{result: "stubbed"}]
    end).(input, options)
  end

  def run(prompt, options) do
    Application.get_env(:jido_amp, :stub_amp_sdk_run, fn _prompt, _options -> {:ok, "stubbed"} end).(
      prompt,
      options
    )
  end

  def create_user_message(text), do: %{type: "user", content: text}
  def create_permission(tool, action, opts \\ []), do: %{tool: tool, action: action, opts: opts}

  def threads_new(opts \\ []), do: {:ok, {:threads_new, opts}}
  def threads_list(opts \\ []), do: {:ok, {:threads_list, opts}}
  def threads_list_raw(opts \\ []), do: {:ok, {:threads_list_raw, opts}}
  def threads_search(query, opts \\ []), do: {:ok, {:threads_search, query, opts}}
  def threads_markdown(thread_id), do: {:ok, {:threads_markdown, thread_id}}
  def threads_share(thread_id, opts \\ []), do: {:ok, {:threads_share, thread_id, opts}}
  def threads_rename(thread_id, name), do: {:ok, {:threads_rename, thread_id, name}}
  def threads_archive(thread_id), do: {:ok, {:threads_archive, thread_id}}
  def threads_delete(thread_id), do: {:ok, {:threads_delete, thread_id}}
  def threads_handoff(thread_id, opts \\ []), do: {:ok, {:threads_handoff, thread_id, opts}}
  def threads_replay(thread_id, opts \\ []), do: {:ok, {:threads_replay, thread_id, opts}}

  def tools_list, do: {:ok, :tools_list}
  def tools_show(tool_name), do: {:ok, {:tools_show, tool_name}}
  def tools_use(tool_name, opts \\ []), do: {:ok, {:tools_use, tool_name, opts}}
  def tools_make(tool_name, opts \\ []), do: {:ok, {:tools_make, tool_name, opts}}

  def tasks_list, do: {:ok, :tasks_list}
  def tasks_import(json_file, opts \\ []), do: {:ok, {:tasks_import, json_file, opts}}

  def review(opts \\ []), do: {:ok, {:review, opts}}

  def skills_add(source), do: {:ok, {:skills_add, source}}
  def skills_list, do: {:ok, :skills_list}
  def skills_remove(name), do: {:ok, {:skills_remove, name}}
  def skills_info(name), do: {:ok, {:skills_info, name}}

  def permissions_list(opts \\ []), do: {:ok, {:permissions_list, opts}}
  def permissions_list_raw(opts \\ []), do: {:ok, {:permissions_list_raw, opts}}
  def permissions_test(tool_name, opts \\ []), do: {:ok, {:permissions_test, tool_name, opts}}
  def permissions_add(tool, action, opts \\ []), do: {:ok, {:permissions_add, tool, action, opts}}

  def mcp_add(name, command_or_url, opts \\ []), do: {:ok, {:mcp_add, name, command_or_url, opts}}
  def mcp_list(opts \\ []), do: {:ok, {:mcp_list, opts}}
  def mcp_list_raw(opts \\ []), do: {:ok, {:mcp_list_raw, opts}}
  def mcp_remove(name), do: {:ok, {:mcp_remove, name}}
  def mcp_doctor, do: {:ok, :mcp_doctor}
  def mcp_approve(name), do: {:ok, {:mcp_approve, name}}
  def mcp_oauth_login(server_name, opts \\ []), do: {:ok, {:mcp_oauth_login, server_name, opts}}
  def mcp_oauth_logout(server_name, opts \\ []), do: {:ok, {:mcp_oauth_logout, server_name, opts}}
  def mcp_oauth_status(server_name, opts \\ []), do: {:ok, {:mcp_oauth_status, server_name, opts}}

  def usage, do: {:ok, :usage}
end

defmodule Jido.Amp.Test.StubAmpModule do
  @moduledoc false

  def cli_installed?(_opts \\ []) do
    Application.get_env(:jido_amp, :stub_amp_cli_installed?, true)
  end
end

defmodule Jido.Amp.Test.StubInstaller do
  @moduledoc false

  def ensure_installed(opts \\ []) do
    Application.get_env(:jido_amp, :stub_ensure_installed, fn _opts ->
      {:ok, %{status: :already_installed, program: "/tmp/amp"}}
    end).(opts)
  end
end

defmodule Jido.Amp.Test.StubStreamRunner do
  @moduledoc false

  def run(args) do
    send(args.agent_pid, {:stub_stream_runner_run, args})
    :ok
  end
end
