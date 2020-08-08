defmodule Timespectre.Plug do
  use Plug.Router

  plug Plug.Logger
  plug :match
  plug Plug.Static, at: "/", from: "../dist/"
  plug :dispatch

  forward "/api", to: Timespectre.ApiPlug

  get "/" do
    if Timespectre.Authentication.authenticated?(conn) do
      send_file(conn, 200, "../dist/index.html")
    else
      send_file(conn, 200, "../dist/login.html")
    end
  end

  get "/logout" do
    conn
      |> Timespectre.Authentication.unauthenticate
      |> put_resp_header("location", "/")
      |> send_resp(303, "")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
