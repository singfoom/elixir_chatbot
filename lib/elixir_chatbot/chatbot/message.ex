defmodule ElixirChatbot.Chatbot.Message do
  @moduledoc """
  A Message is the representation of a message sent to the
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "chatbot_messages" do
    field :content, :string
    field :role, :string

    belongs_to :conversation, ElixirChatbot.Chatbot.Conversation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:role, :content])
    |> validate_required([:content])
  end
end
