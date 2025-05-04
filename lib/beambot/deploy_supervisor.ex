defmodule Beambot.DeploySupervisor do
  @moduledoc false
  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, :ok, name: :deploy_supervisor)
  end

  @impl true
  def init(_) do
    children = [
      {DynamicSupervisor, name: :dynamic_deploy_sup}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
