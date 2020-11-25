defmodule Conv.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      # Conv.Repo,
      # Start the Telemetry supervisor
      ConvWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Conv.PubSub},
      # Start the Endpoint (http/https)
      ConvWeb.Endpoint,
      # Start a worker by calling: Conv.Worker.start_link(arg)
      # {Conv.Worker, arg}
      %{
        id: Conv.ConversationSupervisor,
        start: {Conv.ConversationSupervisor, :start_link, [[]]}
      },
      {Horde.Registry, keys: :unique, name: ConversationRegistry, members: :auto}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Conv.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ConvWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
