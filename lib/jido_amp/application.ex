defmodule Jido.Amp.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Supervisor tree for Jido.Amp components
      # Add supervised processes here as needed
    ]

    opts = [strategy: :one_for_one, name: Jido.Amp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
