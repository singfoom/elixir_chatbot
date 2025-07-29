defmodule ElixirChatbot.Chatbot.ClaudeServiceTest do
  use ExUnit.Case, async: true
  alias ElixirChatbot.Chatbot.ClaudeService
  import Plug.Conn

  describe "call/2" do
    test "returns a response when given a valid prompt" do
      prompt = %{"role" => "user", "content" => "What is Elixir?"}

      Req.Test.stub(ClaudeService, fn conn ->
        Req.Test.json(conn, %{
          "content" => [
            %{
              "text" =>
                "Elixir is a dynamic, functional language designed for building maintainable and scalable applications."
            }
          ]
        })
      end)

      result = ClaudeService.call(prompt, test_plug: ClaudeService)

      assert is_binary(result)
      assert String.contains?(result, "Elixir")
    end

    test "returns empty JSON when response has no content" do
      prompt = %{"role" => "user", "content" => "What is Elixir?"}

      Req.Test.stub(ClaudeService, fn conn ->
        Req.Test.json(conn, %{"content" => []})
      end)

      result = ClaudeService.call(prompt, test_plug: ClaudeService)

      assert result == "{}"
    end

    @tag :capture_log
    test "returns error tuple when request fails" do
      prompt = %{"role" => "user", "content" => "What is Elixir?"}

      Req.Test.stub(ClaudeService, fn conn ->
        Req.Test.transport_error(conn, :timeout)
      end)

      result = ClaudeService.call(prompt, test_plug: ClaudeService)

      assert {:error, %{reason: :timeout}} = result
    end

    test "includes system prompt in messages" do
      prompt = %{"role" => "user", "content" => "What is Elixir?"}

      Req.Test.stub(ClaudeService, fn conn ->
        # Capture the request body to verify system prompt is included
        {:ok, body, _conn} = Plug.Conn.read_body(conn)
        {:ok, decoded_body} = Jason.decode(body)
        messages = decoded_body["messages"]

        # Should have system prompt first, then user prompt
        assert length(messages) == 2
        assert hd(messages)["role"] == "user"

        assert String.contains?(
                 hd(messages)["content"],
                 "chatbot that only answers questions about the programming language Elixir"
               )

        Req.Test.json(conn, %{
          "content" => [%{"text" => "Test response"}]
        })
      end)

      ClaudeService.call(prompt, test_plug: ClaudeService)
    end

    test "uses correct model and parameters" do
      prompt = %{"role" => "user", "content" => "What is Elixir?"}

      Req.Test.stub(ClaudeService, fn conn ->
        {:ok, body, _conn} = Plug.Conn.read_body(conn)
        {:ok, decoded_body} = Jason.decode(body)

        assert decoded_body["model"] == "claude-3-5-sonnet-20241022"
        assert decoded_body["max_tokens"] == 1024
        assert is_list(decoded_body["messages"])

        Req.Test.json(conn, %{
          "content" => [%{"text" => "Test response"}]
        })
      end)

      ClaudeService.call(prompt, test_plug: ClaudeService)
    end

    test "includes correct headers in request" do
      prompt = %{"role" => "user", "content" => "What is Elixir?"}

      Req.Test.stub(ClaudeService, fn conn ->
        assert conn.request_path == "/v1/messages"
        assert get_req_header(conn, "content-type") == ["application/json"]
        assert get_req_header(conn, "anthropic-version") == ["2023-06-01"]
        assert get_req_header(conn, "x-api-key") != []

        Req.Test.json(conn, %{
          "content" => [%{"text" => "Test response"}]
        })
      end)

      ClaudeService.call(prompt, test_plug: ClaudeService)
    end

    test "handles malformed response content" do
      prompt = %{"role" => "user", "content" => "What is Elixir?"}

      Req.Test.stub(ClaudeService, fn conn ->
        Req.Test.json(conn, %{
          "content" => [
            %{"text" => nil}
          ]
        })
      end)

      result = ClaudeService.call(prompt, test_plug: ClaudeService)

      assert result == "{}"
    end

    test "reverses content array to get latest message" do
      prompt = %{"role" => "user", "content" => "What is Elixir?"}

      Req.Test.stub(ClaudeService, fn conn ->
        Req.Test.json(conn, %{
          "content" => [
            %{"text" => "First message"},
            %{"text" => "Latest message"}
          ]
        })
      end)

      result = ClaudeService.call(prompt, test_plug: ClaudeService)

      assert result == "Latest message"
    end
  end
end
