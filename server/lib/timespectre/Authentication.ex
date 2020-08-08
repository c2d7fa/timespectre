defmodule Timespectre.Authentication do
  import Plug.Conn

  def authenticated?(conn) do
    auth_cookie = fetch_cookies(conn).req_cookies["TimespectreAuthentication"]
    auth_cookie == "hello its me"
  end

  def unauthenticate(conn) do
    IO.puts("Timespectre.Authentication.unauthenticate/1 not implemented") # [TODO]
    conn
  end
end
