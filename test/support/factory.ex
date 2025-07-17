defmodule ElixirChatbot.Factory do
  use ExMachina.Ecto, repo: ElixirChatbot.Repo

  def conversation_factory do
    %ElixirChatbot.Chatbot.Conversation{
      resolved_at: nil
    }
  end

  def message_factory do
    %ElixirChatbot.Chatbot.Message{
      content: "Hello, world!",
      role: "user",
      conversation: build(:conversation)
    }
  end

  def resolved_conversation_factory do
    %ElixirChatbot.Chatbot.Conversation{
      resolved_at: ~N[2023-01-01 12:00:00]
    }
  end

  def bot_message_factory do
    %ElixirChatbot.Chatbot.Message{
      content: "Hi there! How can I help you?",
      role: "bot",
      conversation: build(:conversation)
    }
  end
end