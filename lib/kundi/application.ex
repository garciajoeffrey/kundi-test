defmodule Kundi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias KundiWeb.Endpoint

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Kundi.Repo,
      # Start the Telemetry supervisor
      KundiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Kundi.PubSub},
      # Start the Endpoint (http/https)
      KundiWeb.Endpoint,
      # Start a worker by calling: Kundi.Worker.start_link(arg)
      Kundi
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Kundi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
