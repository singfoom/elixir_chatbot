defmodule ElixirChatbot.Repo.Migrations.CreateChatbotConversations do
  use Ecto.Migration

  def change do
    create table(:chatbot_conversations) do
      add :resolved_at, :naive_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
