defmodule ElixirChatbot.Chatbot do
  @moduledoc """
  The Chatbot context.
  """
  import Ecto.Query, warn: false

  alias ElixirChatbot.Chatbot.ClaudeService
  alias ElixirChatbot.Chatbot.Conversation
  alias ElixirChatbot.Chatbot.Message
  alias ElixirChatbot.Repo

  def list_chatbot_conversations do
    Repo.all(Conversation)
  end

  def create_conversation(attrs \\ %{}) do
    %Conversation{}
    |> Conversation.changeset(attrs)
    |> Repo.insert()
  end

  def update_conversation(%Conversation{} = conversation, attrs) do
    conversation
    |> Conversation.changeset(attrs)
    |> Repo.update()
  end

  def create_message(conversation, attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:conversation, conversation)
    |> Repo.insert()
  end

  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  def generate_response(conversation, messages) do
    last_five_messages =
      Enum.slice(messages, 0..4)
      |> Enum.map(fn %{role: role, content: content} ->
        %{"role" => role, "content" => content}
      end)
      |> Enum.reverse()

    service_response = ClaudeService.call(last_five_messages)

    create_message(conversation, %{"content" => service_response, "role" => "assistant"})
  end
end
