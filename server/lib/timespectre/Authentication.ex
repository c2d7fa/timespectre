defmodule Timespectre.Authentication do
  import Plug.Conn
  alias Timespectre.Database, as: Db

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

  def create_user(username, password) do
    if user_exists? username do
      :user_exists
    else
      add_user_to_database(username, password)
      :ok
    end
  end

  defp add_user_to_database(username, password) do
    password_hash = Bcrypt.hash_pwd_salt(password)
    Db.query!("INSERT INTO users (name, password_hash) VALUES (?1, ?2)", bind: [username, password_hash])
  end

  defp user_exists?(username) do
    Db.query!("SELECT name FROM users WHERE name = ?1", bind: [username])
      |> Enum.empty?
      |> Kernel.not
  end
end
