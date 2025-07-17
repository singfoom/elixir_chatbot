defmodule ElixirChatbot.Chatbot.ConversationTest do
  use ElixirChatbot.DataCase

  alias ElixirChatbot.Chatbot.Conversation

  describe "changeset/2" do
    test "valid changeset with resolved_at" do
      resolved_at = ~N[2023-01-01 12:00:00]
      changeset = Conversation.changeset(%Conversation{}, %{resolved_at: resolved_at})
      
      assert changeset.valid?
      assert changeset.changes.resolved_at == resolved_at
    end

    test "valid changeset without resolved_at" do
      changeset = Conversation.changeset(%Conversation{}, %{})
      
      assert changeset.valid?
      assert changeset.changes == %{}
    end

    test "ignores invalid fields" do
      changeset = Conversation.changeset(%Conversation{}, %{invalid_field: "value"})
      
      assert changeset.valid?
      refute Map.has_key?(changeset.changes, :invalid_field)
    end
  end

  describe "schema" do
    test "has correct fields" do
      conversation = %Conversation{}
      
      assert Map.has_key?(conversation, :resolved_at)
      assert Map.has_key?(conversation, :inserted_at)
      assert Map.has_key?(conversation, :updated_at)
    end
  end

  describe "database integration" do
    test "can insert and retrieve conversation" do
      {:ok, conversation} = 
        %Conversation{}
        |> Conversation.changeset(%{})
        |> Repo.insert()

      assert conversation.id
      assert conversation.inserted_at
      assert conversation.updated_at
      assert is_nil(conversation.resolved_at)

      retrieved = Repo.get(Conversation, conversation.id)
      assert retrieved.id == conversation.id
    end

    test "can update resolved_at" do
      {:ok, conversation} = 
        %Conversation{}
        |> Conversation.changeset(%{})
        |> Repo.insert()

      resolved_at = ~N[2023-01-01 12:00:00]
      {:ok, updated} = 
        conversation
        |> Conversation.changeset(%{resolved_at: resolved_at})
        |> Repo.update()

      assert updated.resolved_at == resolved_at
    end
  end
end