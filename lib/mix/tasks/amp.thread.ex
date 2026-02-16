defmodule Mix.Tasks.Amp.Thread do
  @moduledoc """
  Execute a prompt against an existing Amp thread.

      mix amp.thread THREAD_ID "Continue with this task"

  ## Options

    * `--cwd` - Working directory
    * `--timeout` - Timeout in milliseconds (default: `120000`)
    * `--no-notifications` - Disable sound notifications for this run
    * `--dangerously-allow-all` - Skip permission checks
  """

  @shortdoc "Execute a prompt against an existing Amp thread"

  use Mix.Task

  @switches [
    cwd: :string,
    timeout: :integer,
    no_notifications: :boolean,
    dangerously_allow_all: :boolean
  ]
  @aliases [t: :timeout]

  @impl true
  def run(args) do
    Mix.Task.run("app.start")

    {opts, positional, invalid} =
      OptionParser.parse(args, strict: @switches, aliases: @aliases)

    validate_options!(invalid)

    case positional do
      [thread_id, prompt] ->
        execute_thread(thread_id, prompt, opts)

      _ ->
        Mix.raise("""
        expected THREAD_ID and PROMPT

        Usage:
          mix amp.thread THREAD_ID "Continue with this task" [options]
        """)
    end
  end

  defp execute_thread(thread_id, prompt, opts) do
    unless amp_module().cli_installed?() do
      Mix.raise("Amp CLI not found. Run `mix amp.install` first.")
    end

    cmd_args =
      ["threads", "continue", thread_id, "-x", prompt]
      |> maybe_append_flag(opts[:no_notifications], "--no-notifications")
      |> maybe_append_flag(opts[:dangerously_allow_all], "--dangerously-allow-all")

    run_opts =
      []
      |> maybe_put(:cd, opts[:cwd])
      |> maybe_put(:timeout, opts[:timeout])

    Mix.shell().info(["Executing thread ", :cyan, thread_id, :reset, "..."])

    case command_module().run(cmd_args, run_opts) do
      {:ok, result} ->
        Mix.shell().info(result)

      {:error, reason} ->
        Mix.raise("Amp thread execution failed: #{format_error(reason)}")
    end
  end

  defp validate_options!([]), do: :ok

  defp validate_options!(invalid) do
    invalid_text =
      Enum.map_join(invalid, ", ", fn
        {name, nil} -> format_invalid_name(name)
        {name, value} -> "#{format_invalid_name(name)}=#{value}"
      end)

    Mix.raise("invalid options: #{invalid_text}")
  end

  defp maybe_put(opts, _key, nil), do: opts
  defp maybe_put(opts, key, value), do: Keyword.put(opts, key, value)

  defp maybe_append_flag(args, true, flag), do: args ++ [flag]
  defp maybe_append_flag(args, _value, _flag), do: args

  defp format_error(%{message: message}) when is_binary(message), do: message
  defp format_error(reason), do: inspect(reason)

  defp format_invalid_name(name) when is_binary(name) do
    if String.starts_with?(name, "-"), do: name, else: "--#{name}"
  end

  defp format_invalid_name(name) when is_atom(name), do: "--#{name}"

  defp amp_module do
    Application.get_env(:jido_amp, :amp_module, Jido.Amp)
  end

  defp command_module do
    Application.get_env(:jido_amp, :amp_command_module, AmpSdk.Command)
  end
end
