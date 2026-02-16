defmodule Jido.Amp.StreamRunnerTest do
  use ExUnit.Case, async: true

  alias AmpSdk.Types.{ErrorResultMessage, ResultMessage, SystemMessage}
  alias Jido.Amp.StreamRunner

  describe "run/1" do
    test "dispatches each streamed SDK message to the agent pid" do
      options = %AmpSdk.Types.Options{}

      StreamRunner.run(%{
        agent_pid: self(),
        prompt: "hello",
        options: options,
        compatibility_check: fn -> :ok end,
        executor: fn "hello", ^options ->
          [
            %SystemMessage{session_id: "s1", cwd: "/tmp", tools: []},
            %ResultMessage{session_id: "s1", result: "done", num_turns: 1, duration_ms: 10}
          ]
        end
      })

      assert_receive {:signal, first}
      assert first.type == "amp.internal.message"
      assert %SystemMessage{} = first.data.message

      assert_receive {:signal, second}
      assert second.type == "amp.internal.message"
      assert %ResultMessage{} = second.data.message
    end

    test "dispatches error signal when compatibility check fails" do
      options = %AmpSdk.Types.Options{}

      StreamRunner.run(%{
        agent_pid: self(),
        prompt: "hello",
        options: options,
        compatibility_check: fn -> {:error, %{message: "incompatible"}} end,
        executor: fn _prompt, _opts -> [] end
      })

      assert_receive {:signal, signal}
      assert signal.type == "amp.internal.message"
      assert %ErrorResultMessage{is_error: true, error: "incompatible"} = signal.data.message
    end

    test "dispatches error signal when executor raises" do
      options = %AmpSdk.Types.Options{}

      StreamRunner.run(%{
        agent_pid: self(),
        prompt: "hello",
        options: options,
        compatibility_check: fn -> :ok end,
        executor: fn _prompt, _opts -> raise "boom" end
      })

      assert_receive {:signal, signal}
      assert signal.type == "amp.internal.message"
      assert %ErrorResultMessage{is_error: true, error: error} = signal.data.message
      assert error =~ "boom"
    end
  end
end
