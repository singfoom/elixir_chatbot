defmodule ElixirChatbot.Repo do
  use Ecto.Repo,
    otp_app: :elixir_chatbot,
    adapter: Ecto.Adapters.Postgres
end
