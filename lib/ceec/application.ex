defmodule Ceec.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CeecWeb.Telemetry,
      Ceec.Repo,
      {DNSCluster, query: Application.get_env(:ceec, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Ceec.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Ceec.Finch},
      # Start a worker by calling: Ceec.Worker.start_link(arg)
      # {Ceec.Worker, arg},
      # Start to serve requests, typically the last entry
      CeecWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ceec.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CeecWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
