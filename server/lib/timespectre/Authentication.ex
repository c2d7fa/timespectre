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
    password_hashes = Db.query!("SELECT password_hash FROM users WHERE name = ?1", bind: [username])
    unless Enum.empty?(password_hashes) do
      [[password_hash: password_hash]] = password_hashes
      Bcrypt.verify_pass(password, password_hash)
    else
      IO.puts("Someone attempted to log in to non-existent account '#{username}'.")
      false
    end
  end

  def authenticate(conn, username) do
    token = random_string(32)
    Agent.update(__MODULE__, fn sessions -> Map.put(sessions, token, username) end)
    put_resp_cookie(conn, "TimespectreAuthentication", token)
  end

  defp random_string(bytes) do
    :crypto.strong_rand_bytes(bytes) |> Base.hex_encode32(padding: false)
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
