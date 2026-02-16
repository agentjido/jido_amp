defmodule Jido.Amp.Integration.ThreadsTest do
  use ExUnit.Case

  alias Jido.Amp

  @moduletag :integration

  test "threads_list returns a result tuple" do
    result = Amp.threads_list(limit: 5)
    assert match?({:ok, _}, result) or match?({:error, _}, result)
  end
end
