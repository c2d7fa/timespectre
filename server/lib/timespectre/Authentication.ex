defmodule Timespectre.Authentication do
  import Plug.Conn

  def authenticated?(conn) do
    not is_nil(authenticated_user(conn))
  end

  def authenticated_user(conn) do
    auth_cookie = fetch_cookies(conn).req_cookies["TimespectreAuthentication"]
    if auth_cookie == "hello its me" do
      "test"
    else
      nil
    end
  end

  def correct_credentials?(username, password) do
    if username == "test" do
      true
    else
      false
    end
  end

  def authenticate(conn, username) do
    put_resp_cookie(conn, "TimespectreAuthentication", "hello its me")
  end

  def unauthenticate(conn) do
    delete_resp_cookie(conn, "TimespectreAuthentication")
  end
end
