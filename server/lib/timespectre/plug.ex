defmodule Timespectre.Plug do
  use Plug.Router

  plug :match
  plug Plug.Static, at: "/", from: "../dist/"
  plug :dispatch

  get "/api/counter" do
    conn |> send_resp(200, "2")
  end

  post "/api/counter/increment" do
    IO.puts("Increment")
    conn |> send_resp(501, "TODO")
  end

  post "/api/counter/decrement" do
    IO.puts("Decrement")
    conn |> send_resp(501, "TODO")
  end

  match _ do
    conn |> send_resp(404, "Not found")
  end
end

