defmodule NewWorldSimulation.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      NewWorldSimulationWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: NewWorldSimulation.PubSub},
      # Start the Endpoint (http/https)
      NewWorldSimulationWeb.Endpoint,
      # The grid maintaining the game state
      NewWorldSimulation.Grid
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NewWorldSimulation.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    NewWorldSimulationWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
