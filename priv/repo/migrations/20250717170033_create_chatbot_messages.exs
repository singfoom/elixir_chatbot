defmodule ElixirChatbot.Repo.Migrations.CreateChatbotMessages do
  use Ecto.Migration

  def change do
    create table(:chatbot_messages) do
      add :conversation_id, references(:chatbot_conversations, on_delete: :nothing)
      add :content, :string
      add :role, :string

      timestamps(type: :utc_datetime)
    end

    create index(:chatbot_messages, [:conversation_id])
  end
end
