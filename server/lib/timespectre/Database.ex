defmodule Timespectre.Database do
  def start_link(path, opts \\ []) do
    result = Sqlitex.Server.start_link(path, opts)
    case result do
      {:ok, pid} -> initialize_tables(pid)
      _ -> nil
    end
    result
  end

  defp initialize_tables(db) do
    query! db, """
      CREATE TABLE IF NOT EXISTS sessions (
        id TEXT PRIMARY KEY,
        start INTEGER NOT NULL,
        end INTEGER,
        notes TEXT NOT NULL DEFAULT '',
        deleted INTEGER DEFAULT 0
      )
      """
    query! db, """
      CREATE TABLE IF NOT EXISTS session_tags (
        session_id TEXT REFERENCES sessions(id),
        tag TEXT NOT NULL,
        PRIMARY KEY (session_id, tag)
      )
      """
  end

  def query!(db, sql, opts \\ []) do
    {:ok, result} = Sqlitex.Server.query db, sql, opts
    result
  end
end
