defmodule Timespectre.AuthenticationPlug do
  import Plug.Conn
  alias Timespectre.Authentication, as: Auth

  def authenticated_user(conn) do
    conn.assigns[:authenticated_user]
  end

  defmacro conn_user do
    quote do
      Timespectre.AuthenticationPlug.authenticated_user(var!(conn))
    end
  end

  def init(_opts), do: nil

  def call(conn, _opts) do
    if Auth.authenticated?(conn) do
      assign(conn, :authenticated_user, Auth.authenticated_user(conn))
    else
      conn |> send_resp(401, "Not Authenticated") |> halt
    end
  end
end
