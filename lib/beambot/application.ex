defmodule Beambot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BeambotWeb.Telemetry,
      Beambot.Repo,
      {DNSCluster, query: Application.get_env(:beambot, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Beambot.PubSub},
      {BeamBot.Genservers.TokenManager, %{}},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Beambot.Finch},
      {Registry, keys: :unique, name: BeamBot.Registry},
      Beambot.DeploySupervisor,
      # Start a worker by calling: Beambot.Worker.start_link(arg)
      # {Beambot.Worker, arg},
      # Start to serve requests, typically the last entry
      BeambotWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Beambot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BeambotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
