defmodule Timespectre.AuthenticationPlug do
  import Plug.Conn
  import Timespectre.Authentication

  def init(_opts), do: nil

  def call(conn, _opts) do
    if authenticated?(conn) do
      conn
    else
      conn |> send_resp(401, "Not Authenticated") |> halt
    end
  end
end
