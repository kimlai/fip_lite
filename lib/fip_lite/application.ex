defmodule FipLite.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      FipLiteWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: FipLite.PubSub},
      # Start the Endpoint (http/https)
      FipLiteWeb.Endpoint,
      {Finch, name: FipLiteFinch},
      # Start a worker by calling: FipLite.Worker.start_link(arg)
      FipLite.NowPlaying
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FipLite.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    FipLiteWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
