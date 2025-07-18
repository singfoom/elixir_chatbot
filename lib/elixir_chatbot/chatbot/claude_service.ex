defmodule ElixirChatbot.Chatbot.ClaudeService do
  @moduledoc """
  ClaudeService contains functions to connect to the Anthropic messages
  API via Req.
  """

  defp default_system_prompt do
    """
    You are a chatbot that only answers questions about the programming language Elixir.
    Answer short with just a 1-3 sentences.
    If the question is about another programming language, make a joke about it.
    If the question is about something else, answer something like:
    "I dont know, its not my cup of tea" or "I have no opinion about that topic".
    """
  end

  def call(prompt, opts \\ []) do
    default_message = %{"role" => "user", "content" => default_system_prompt()}

    messages = [prompt]
    messages = [default_message | messages]

    incoming_body =
      %{
        "model" => "claude-3-5-sonnet-20241022",
        "max_tokens" => 1024,
        "messages" => messages
      }

    incoming_body
    |> Jason.encode!()
    |> request(opts)
    |> parse_response()
  end

  defp parse_response({:ok, %Req.Response{body: body}}) do
    messages =
      Map.get(body, "content", [])
      |> Enum.reverse()

    case messages do
      [%{"text" => message} | _] -> message
      _ -> "{}"
    end
  end

  defp parse_response(error) do
    error
  end

  defp request(body, _opts) do
    Req.post("https://api.anthropic.com/v1/messages", headers: headers(), body: body)
  end

  defp headers do
    [
      {"Content-Type", "application/json"},
      {"x-api-key", "#{Application.get_env(:elixir_chatbot, :anthropic_key)}"},
      {"anthropic-version", "2023-06-01"}
    ]
  end
end
