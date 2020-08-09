defmodule Timespectre.Plug do
  use Plug.Router
  alias Timespectre.Authentication, as: Auth

  plug Plug.Logger
  plug Plug.Parsers, parsers: [:urlencoded]
  plug :match
  plug Plug.Static, at: "/", from: "../dist/"
  plug :dispatch

  forward "/api", to: Timespectre.ApiPlug

  get "/" do
    if Auth.authenticated?(conn) do
      send_file(conn, 200, "../dist/index.html")
    else
      send_file(conn, 200, "../dist/login.html")
    end
  end

  post "/" do
    cond do
      Map.has_key?(conn.body_params, "login") ->
        if Auth.correct_credentials?(conn.body_params["username"], conn.body_params["password"]) do
          conn
            |> Auth.authenticate(conn.body_params["username"])
            |> send_file(200, "../dist/index.html")
        else
          IO.puts("incorrect password")
        end
      Map.has_key?(conn.body_params, "signup") ->
        IO.puts("signup")
      true ->
        IO.puts("error")
    end
  end

  get "/logout" do
    conn
      |> Auth.unauthenticate
      |> put_resp_header("location", "/")
      |> send_resp(303, "")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
