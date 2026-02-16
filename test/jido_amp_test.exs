defmodule Jido.AmpTest do
  use ExUnit.Case
  doctest Jido.Amp

  alias Jido.Amp.Error.ConfigError
  alias Jido.Amp.Test.{StubAmpSdk, StubCLI, StubCommand}

  setup do
    old_amp_sdk = Application.get_env(:jido_amp, :amp_sdk_module)
    old_cli_module = Application.get_env(:jido_amp, :amp_cli_module)
    old_command_module = Application.get_env(:jido_amp, :amp_command_module)
    old_cli_resolve = Application.get_env(:jido_amp, :stub_cli_resolve)
    old_command_run = Application.get_env(:jido_amp, :stub_command_run)
    old_amp_run = Application.get_env(:jido_amp, :stub_amp_sdk_run)
    old_amp_execute = Application.get_env(:jido_amp, :stub_amp_sdk_execute)

    Application.put_env(:jido_amp, :amp_sdk_module, StubAmpSdk)
    Application.put_env(:jido_amp, :amp_cli_module, StubCLI)
    Application.put_env(:jido_amp, :amp_command_module, StubCommand)
    Application.put_env(:jido_amp, :stub_cli_resolve, fn -> {:ok, %{program: "/tmp/amp"}} end)

    Application.put_env(:jido_amp, :stub_command_run, fn
      ["--help"], _opts -> {:ok, "amp --execute --stream-json"}
      ["--version"], _opts -> {:ok, "1.0.0"}
      _args, _opts -> {:ok, "ok"}
    end)

    on_exit(fn ->
      restore_env(:jido_amp, :amp_sdk_module, old_amp_sdk)
      restore_env(:jido_amp, :amp_cli_module, old_cli_module)
      restore_env(:jido_amp, :amp_command_module, old_command_module)
      restore_env(:jido_amp, :stub_cli_resolve, old_cli_resolve)
      restore_env(:jido_amp, :stub_command_run, old_command_run)
      restore_env(:jido_amp, :stub_amp_sdk_run, old_amp_run)
      restore_env(:jido_amp, :stub_amp_sdk_execute, old_amp_execute)
    end)

    :ok
  end

  describe "version/0" do
    test "returns the version" do
      version = Jido.Amp.version()
      assert is_binary(version)
      assert version =~ ~r/^\d+\.\d+\.\d+$/
    end
  end

  describe "cli_installed?/0" do
    test "returns true when CLI resolves" do
      assert Jido.Amp.cli_installed?() == true
    end

    test "returns false when CLI resolution fails" do
      Application.put_env(:jido_amp, :stub_cli_resolve, fn -> {:error, :enoent} end)
      assert Jido.Amp.cli_installed?() == false
    end
  end

  describe "compatibility helpers" do
    test "compatible?/0 and assert_compatible!/0 report healthy state" do
      assert Jido.Amp.compatible?() == true
      assert Jido.Amp.assert_compatible!() == :ok
    end

    test "execute/2 raises ConfigError when incompatible" do
      Application.put_env(:jido_amp, :stub_command_run, fn
        ["--help"], _opts -> {:ok, "amp --execute"}
        ["--version"], _opts -> {:ok, "1.0.0"}
        _args, _opts -> {:ok, "ok"}
      end)

      assert_raise ConfigError, fn ->
        Jido.Amp.execute("test prompt")
      end
    end

    test "run/2 returns config error tuple when incompatible" do
      Application.put_env(:jido_amp, :stub_command_run, fn
        ["--help"], _opts -> {:ok, "amp --execute"}
        ["--version"], _opts -> {:ok, "1.0.0"}
        _args, _opts -> {:ok, "ok"}
      end)

      assert {:error, %ConfigError{key: :amp_cli_streaming_compatibility}} =
               Jido.Amp.run("test prompt")
    end
  end

  describe "run/2 and execute/2" do
    test "run/2 delegates to amp_sdk module with normalized options" do
      Application.put_env(:jido_amp, :stub_amp_sdk_run, fn prompt, options ->
        send(self(), {:stub_run_called, prompt, options})
        {:ok, "done"}
      end)

      assert {:ok, "done"} = Jido.Amp.run("ship it", mode: "smart", no_color: true)
      assert_receive {:stub_run_called, "ship it", %AmpSdk.Types.Options{} = options}
      assert options.mode == "smart"
      assert options.no_color == true
    end

    test "execute/2 delegates to amp_sdk module with normalized options" do
      Application.put_env(:jido_amp, :stub_amp_sdk_execute, fn prompt, options ->
        send(self(), {:stub_execute_called, prompt, options})
        [%AmpSdk.Types.ResultMessage{result: "done"}]
      end)

      messages = Jido.Amp.execute("stream it", mode: "smart") |> Enum.to_list()

      assert_receive {:stub_execute_called, "stream it", %AmpSdk.Types.Options{} = options}
      assert options.mode == "smart"
      assert [%AmpSdk.Types.ResultMessage{result: "done"}] = messages
    end
  end

  describe "helpers and curated delegates" do
    test "create helpers delegate to sdk" do
      assert %{type: "user", content: "hello"} = Jido.Amp.create_user_message("hello")

      assert %{tool: "Read", action: "allow", opts: [to: "workspace"]} =
               Jido.Amp.create_permission("Read", "allow", to: "workspace")
    end

    test "curated management operations delegate through modules" do
      assert {:ok, {:threads_list, [limit: 5]}} = Jido.Amp.threads_list(limit: 5)
      assert {:ok, {:threads_search, "bug", [limit: 2]}} = Jido.Amp.threads_search("bug", limit: 2)
      assert {:ok, {:threads_markdown, "th_1"}} = Jido.Amp.threads_markdown("th_1")
      assert {:ok, :tools_list} = Jido.Amp.tools_list()
      assert {:ok, {:permissions_list, [scope: "workspace"]}} = Jido.Amp.permissions_list(scope: "workspace")
      assert {:ok, {:mcp_list, [format: :parsed]}} = Jido.Amp.mcp_list(format: :parsed)
      assert {:ok, :usage} = Jido.Amp.usage()
    end
  end

  defp restore_env(app, key, nil), do: Application.delete_env(app, key)
  defp restore_env(app, key, value), do: Application.put_env(app, key, value)
end
