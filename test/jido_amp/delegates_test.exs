defmodule Jido.Amp.DelegatesTest do
  use ExUnit.Case, async: true

  alias Jido.Amp.{MCP, Permissions, Review, Skills, Tasks, Threads, Tools}
  alias Jido.Amp.Test.StubAmpSdk

  setup do
    old_amp_sdk = Application.get_env(:jido_amp, :amp_sdk_module)
    Application.put_env(:jido_amp, :amp_sdk_module, StubAmpSdk)

    on_exit(fn ->
      if old_amp_sdk do
        Application.put_env(:jido_amp, :amp_sdk_module, old_amp_sdk)
      else
        Application.delete_env(:jido_amp, :amp_sdk_module)
      end
    end)

    :ok
  end

  describe "threads wrappers" do
    test "delegates all thread operations" do
      assert {:ok, {:threads_new, [title: "new"]}} = Threads.new(title: "new")
      assert {:ok, {:threads_list, [limit: 10]}} = Threads.list(limit: 10)
      assert {:ok, {:threads_list_raw, [format: :json]}} = Threads.list_raw(format: :json)
      assert {:ok, {:threads_search, "find me", [limit: 5]}} = Threads.search("find me", limit: 5)
      assert {:ok, {:threads_markdown, "th_1"}} = Threads.markdown("th_1")
      assert {:ok, {:threads_share, "th_1", [visibility: "private"]}} = Threads.share("th_1", visibility: "private")
      assert {:ok, {:threads_rename, "th_1", "new title"}} = Threads.rename("th_1", "new title")
      assert {:ok, {:threads_archive, "th_1"}} = Threads.archive("th_1")
      assert {:ok, {:threads_delete, "th_1"}} = Threads.delete("th_1")
      assert {:ok, {:threads_handoff, "th_1", [to: "agent"]}} = Threads.handoff("th_1", to: "agent")
      assert {:ok, {:threads_replay, "th_1", [from: 1]}} = Threads.replay("th_1", from: 1)
    end
  end

  describe "tools wrappers" do
    test "delegates all tool operations" do
      assert {:ok, :tools_list} = Tools.list()
      assert {:ok, {:tools_show, "Read"}} = Tools.show("Read")
      assert {:ok, {:tools_use, "Read", [path: "README.md"]}} = Tools.use("Read", path: "README.md")
      assert {:ok, {:tools_make, "MyTool", [script: "echo hi"]}} = Tools.make("MyTool", script: "echo hi")
    end
  end

  describe "permissions wrappers" do
    test "delegates permission operations" do
      assert {:ok, {:permissions_list, [scope: :workspace]}} = Permissions.list(scope: :workspace)
      assert {:ok, {:permissions_list_raw, [scope: :workspace]}} = Permissions.list_raw(scope: :workspace)
      assert {:ok, {:permissions_test, "Read", [path: "README.md"]}} = Permissions.test("Read", path: "README.md")

      assert {:ok, {:permissions_add, "Read", "allow", [to: "workspace"]}} =
               Permissions.add("Read", "allow", to: "workspace")
    end
  end

  describe "mcp wrappers" do
    test "delegates mcp operations" do
      assert {:ok, {:mcp_add, "srv", "npx", [args: ["foo"]]}} = MCP.add("srv", "npx", args: ["foo"])
      assert {:ok, {:mcp_list, [format: :parsed]}} = MCP.list(format: :parsed)
      assert {:ok, {:mcp_list_raw, [format: :json]}} = MCP.list_raw(format: :json)
      assert {:ok, {:mcp_remove, "srv"}} = MCP.remove("srv")
      assert {:ok, :mcp_doctor} = MCP.doctor()
      assert {:ok, {:mcp_approve, "srv"}} = MCP.approve("srv")
      assert {:ok, {:mcp_oauth_login, "srv", [profile: "default"]}} = MCP.oauth_login("srv", profile: "default")
      assert {:ok, {:mcp_oauth_logout, "srv", [profile: "default"]}} = MCP.oauth_logout("srv", profile: "default")
      assert {:ok, {:mcp_oauth_status, "srv", [profile: "default"]}} = MCP.oauth_status("srv", profile: "default")
    end
  end

  describe "tasks, review, skills wrappers" do
    test "delegates tasks" do
      assert {:ok, :tasks_list} = Tasks.list()
      assert {:ok, {:tasks_import, "tasks.json", [replace: true]}} = Tasks.import("tasks.json", replace: true)
    end

    test "delegates review" do
      assert {:ok, {:review, [cwd: "/tmp"]}} = Review.run(cwd: "/tmp")
    end

    test "delegates skills" do
      assert {:ok, {:skills_add, "github:org/repo"}} = Skills.add("github:org/repo")
      assert {:ok, :skills_list} = Skills.list()
      assert {:ok, {:skills_remove, "my-skill"}} = Skills.remove("my-skill")
      assert {:ok, {:skills_info, "my-skill"}} = Skills.info("my-skill")
    end
  end
end
