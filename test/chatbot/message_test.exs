defmodule ElixirChatbot.Chatbot.MessageTest do
  use ElixirChatbot.DataCase

  alias ElixirChatbot.Chatbot.{Message, Conversation}

  describe "changeset/2" do
    test "valid changeset with all fields" do
      changeset = Message.changeset(%Message{}, %{
        role: "user",
        content: "Hello, world!"
      })
      
      assert changeset.valid?
      assert changeset.changes.role == "user"
      assert changeset.changes.content == "Hello, world!"
    end

    test "valid changeset with only required content" do
      changeset = Message.changeset(%Message{}, %{content: "Test message"})
      
      assert changeset.valid?
      assert changeset.changes.content == "Test message"
    end

    test "invalid changeset without required content" do
      changeset = Message.changeset(%Message{}, %{role: "user"})
      
      refute changeset.valid?
      assert changeset.errors[:content] == {"can't be blank", [validation: :required]}
    end

    test "invalid changeset with empty content" do
      changeset = Message.changeset(%Message{}, %{content: ""})
      
      refute changeset.valid?
      assert changeset.errors[:content] == {"can't be blank", [validation: :required]}
    end

    test "ignores invalid fields" do
      changeset = Message.changeset(%Message{}, %{
        content: "Valid content",
        invalid_field: "should be ignored"
      })
      
      assert changeset.valid?
      refute Map.has_key?(changeset.changes, :invalid_field)
    end
  end

  describe "schema" do
    test "has correct fields" do
      message = %Message{}
      
      assert Map.has_key?(message, :content)
      assert Map.has_key?(message, :role)
      assert Map.has_key?(message, :conversation_id)
      assert Map.has_key?(message, :inserted_at)
      assert Map.has_key?(message, :updated_at)
    end
  end

  describe "database integration" do
    test "can insert and retrieve message" do
      {:ok, conversation} = 
        %Conversation{}
        |> Conversation.changeset(%{})
        |> Repo.insert()

      {:ok, message} = 
        %Message{}
        |> Message.changeset(%{
          content: "Test message",
          role: "user"
        })
        |> Ecto.Changeset.put_assoc(:conversation, conversation)
        |> Repo.insert()

      assert message.id
      assert message.content == "Test message"
      assert message.role == "user"
      assert message.conversation_id == conversation.id
      assert message.inserted_at
      assert message.updated_at

      retrieved = Repo.get(Message, message.id)
      assert retrieved.id == message.id
      assert retrieved.content == message.content
    end

    test "can update message content" do
      {:ok, conversation} = 
        %Conversation{}
        |> Conversation.changeset(%{})
        |> Repo.insert()

      {:ok, message} = 
        %Message{}
        |> Message.changeset(%{content: "Original content"})
        |> Ecto.Changeset.put_assoc(:conversation, conversation)
        |> Repo.insert()

      {:ok, updated} = 
        message
        |> Message.changeset(%{content: "Updated content"})
        |> Repo.update()

      assert updated.content == "Updated content"
    end

    test "belongs to conversation" do
      {:ok, conversation} = 
        %Conversation{}
        |> Conversation.changeset(%{})
        |> Repo.insert()

      {:ok, message} = 
        %Message{}
        |> Message.changeset(%{content: "Test message"})
        |> Ecto.Changeset.put_assoc(:conversation, conversation)
        |> Repo.insert()

      loaded_message = Repo.get(Message, message.id) |> Repo.preload(:conversation)
      assert loaded_message.conversation.id == conversation.id
    end
  end
end