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

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
