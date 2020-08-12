defmodule Timespectre.AuthenticationPlug do
  import Plug.Conn
  alias Timespectre.Authentication, as: Auth

  def init(_opts), do: nil

  def call(conn, _opts) do
      conn
    if Auth.authenticated?(conn) do
    else
      conn |> send_resp(401, "Not Authenticated") |> halt
    end
  end
end
