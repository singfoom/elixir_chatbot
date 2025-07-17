defmodule ElixirChatbot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ElixirChatbotWeb.Telemetry,
      ElixirChatbot.Repo,
      {DNSCluster, query: Application.get_env(:elixir_chatbot, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ElixirChatbot.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ElixirChatbot.Finch},
      # Start a worker by calling: ElixirChatbot.Worker.start_link(arg)
      # {ElixirChatbot.Worker, arg},
      # Start to serve requests, typically the last entry
      ElixirChatbotWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirChatbot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElixirChatbotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
