defmodule Timespectre.AuthenticationPlug do
  import Plug.Conn

  def init(_opts), do: nil

  def call(conn, _opts) do
    auth_cookie = fetch_cookies(conn).req_cookies["TimespectreAuthentication"]

    authenticated? = auth_cookie == "hello its me"

    if authenticated? do
      conn
    else
      conn |> send_resp(401, "Not Authenticated") |> halt
    end
  end
end
