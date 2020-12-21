defmodule Timespectre.Plug do
  use Plug.Router
  alias Timespectre.Authentication, as: Auth

  plug Plug.Logger
  plug :match

  # Parse URL encoded text for the login/sign-up page, but let JSON pass through
  # - we may want to use it later for the API.
  plug Plug.Parsers, parsers: [:urlencoded], pass: ["application/json"] 

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
    username = conn.body_params["username"]
    cond do
      Map.has_key?(conn.body_params, "login") ->
        if Auth.correct_credentials?(username, conn.body_params["password"]) do
          conn
            |> Auth.authenticate(username)
            |> put_resp_header("location", "/")
            |> send_resp(303, "")
        else
          send_resp(conn, 401, "The given password is incorrect or the user '#{username}' does not exist.")
        end
      Map.has_key?(conn.body_params, "signup") ->
        case Auth.create_user(username, conn.body_params["password"]) do
          :ok ->
            conn
              |> Auth.authenticate(username)
              |> put_resp_header("location", "/")
              |> send_resp(303, "")
          :user_exists ->
            send_resp(conn, 409, "Error: The user '#{username}' already exists. Try signing up with a different username.")
        end
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
