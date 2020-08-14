defmodule Timespectre.Authentication do
  import Plug.Conn

  use Agent

  def start_link(_opts) do
    # Agent has map of authentication tokens to logged in users.
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def authenticated?(conn) do
    not is_nil(authenticated_user(conn))
  end

  def authenticated_user(conn) do
    auth_cookie = fetch_cookies(conn).req_cookies["TimespectreAuthentication"]
    Agent.get(__MODULE__, fn sessions -> sessions[auth_cookie] end)
  end

  def correct_credentials?(username, password) do
    true # [TODO] Actually check password!
  end

  def authenticate(conn, username) do
    token = "secret#{username}token" # [TODO] Generate secure token!
    Agent.update(__MODULE__, fn sessions -> Map.put(sessions, token, username) end)
    put_resp_cookie(conn, "TimespectreAuthentication", token)
  end

  def unauthenticate(conn) do
    delete_resp_cookie(conn, "TimespectreAuthentication")
  end
end
