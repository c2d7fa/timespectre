defmodule Timespectre.Plug do
  use Plug.Router

  plug Plug.Logger
  plug :match
  plug Plug.Static, at: "/", from: "../dist/"
  plug :dispatch

  forward "/api", to: Timespectre.ApiPlug

  def init(_opts) do
    query! """
      CREATE TABLE IF NOT EXISTS sessions (
        id TEXT PRIMARY KEY,
        start INTEGER NOT NULL,
        end INTEGER,
        notes TEXT NOT NULL DEFAULT '',
        deleted INTEGER DEFAULT 0
      )
      """
    query! """
      CREATE TABLE IF NOT EXISTS session_tags (
        session_id TEXT REFERENCES sessions(id),
        tag TEXT NOT NULL,
        PRIMARY KEY (session_id, tag)
      )
      """
    nil
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  defp query!(sql, opts \\ []) do
    {:ok, result} = Sqlitex.Server.query(Timespectre.DB, sql, opts)
    result
  end
end

