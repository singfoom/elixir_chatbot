defmodule ElixirChatbot.Chatbot.Conversation do
  @moduledoc """
  A schema to hold the records of a conversation with the chatbot.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "chatbot_conversations" do
    field :resolved_at, :naive_datetime

    has_many :messages, ElixirChatbot.Chatbot.Message, preload_order: [desc: :inserted_at]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:resolved_at])
  end
end
