defmodule ElixirChatbot.ChatbotTest do
  use ElixirChatbot.DataCase

  alias ElixirChatbot.Chatbot
  import ElixirChatbot.Factory

  describe "list_chatbot_conversations/0" do
    test "returns all conversations" do
      conversation1 = insert(:conversation)
      conversation2 = insert(:conversation)

      conversations = Chatbot.list_chatbot_conversations()
      
      assert length(conversations) == 2
      assert Enum.any?(conversations, fn c -> c.id == conversation1.id end)
      assert Enum.any?(conversations, fn c -> c.id == conversation2.id end)
    end

    test "returns empty list when no conversations exist" do
      conversations = Chatbot.list_chatbot_conversations()
      assert conversations == []
    end
  end

  describe "create_conversation/1" do
    test "creates conversation with valid attributes" do
      resolved_at = ~N[2023-01-01 12:00:00]
      attrs = %{resolved_at: resolved_at}

      {:ok, conversation} = Chatbot.create_conversation(attrs)

      assert conversation.resolved_at == resolved_at
      assert conversation.id
      assert conversation.inserted_at
      assert conversation.updated_at
    end

    test "creates conversation with no attributes" do
      {:ok, conversation} = Chatbot.create_conversation()

      assert is_nil(conversation.resolved_at)
      assert conversation.id
      assert conversation.inserted_at
      assert conversation.updated_at
    end

    test "creates conversation with empty map" do
      {:ok, conversation} = Chatbot.create_conversation(%{})

      assert is_nil(conversation.resolved_at)
      assert conversation.id
      assert conversation.inserted_at
      assert conversation.updated_at
    end
  end

  describe "update_conversation/2" do
    test "updates conversation with valid attributes" do
      conversation = insert(:conversation)
      resolved_at = ~N[2023-01-01 12:00:00]
      attrs = %{resolved_at: resolved_at}

      {:ok, updated_conversation} = Chatbot.update_conversation(conversation, attrs)

      assert updated_conversation.resolved_at == resolved_at
      assert updated_conversation.id == conversation.id
    end

    test "returns error changeset with invalid attributes" do
      conversation = insert(:conversation)
      attrs = %{resolved_at: "invalid_date"}

      {:error, changeset} = Chatbot.update_conversation(conversation, attrs)

      assert errors_on(changeset).resolved_at
      refute changeset.valid?
    end
  end

  describe "create_message/2" do
    test "creates message with valid attributes" do
      conversation = insert(:conversation)
      attrs = %{content: "Hello, world!", role: "user"}

      {:ok, message} = Chatbot.create_message(conversation, attrs)

      assert message.content == "Hello, world!"
      assert message.role == "user"
      assert message.conversation_id == conversation.id
      assert message.id
      assert message.inserted_at
      assert message.updated_at
    end

    test "creates message with no attributes" do
      conversation = insert(:conversation)

      {:error, changeset} = Chatbot.create_message(conversation)

      assert changeset.errors[:content] == {"can't be blank", [validation: :required]}
      refute changeset.valid?
    end

    test "creates message with empty map" do
      conversation = insert(:conversation)

      {:error, changeset} = Chatbot.create_message(conversation, %{})

      assert changeset.errors[:content] == {"can't be blank", [validation: :required]}
      refute changeset.valid?
    end
  end

  describe "change_message/2" do
    test "returns changeset for existing message" do
      message = insert(:message, content: "Original content")
      
      changeset = Chatbot.change_message(message, %{content: "Updated content"})

      assert changeset.data == message
      assert changeset.changes.content == "Updated content"
      assert changeset.valid?
    end

    test "returns changeset with no attributes" do
      message = insert(:message)
      
      changeset = Chatbot.change_message(message)

      assert changeset.data == message
      assert changeset.changes == %{}
      assert changeset.valid?
    end

    test "returns changeset with empty map" do
      message = insert(:message)
      
      changeset = Chatbot.change_message(message, %{})

      assert changeset.data == message
      assert changeset.changes == %{}
      assert changeset.valid?
    end
  end
end