defmodule Timespectre.Database do
  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, args}
    }
  end

  def start_link(path) do
    result = Sqlitex.Server.start_link(path, name: __MODULE__)
    initialize_tables()
    result
  end

  defp initialize_tables() do
    query! """
      CREATE TABLE IF NOT EXISTS users (
        name TEXT PRIMARY KEY,
        password_hash TEXT NOT NULL
      )
    """
    query! """
      CREATE TABLE IF NOT EXISTS sessions (
        user TEXT REFERENCES users (name),
        id TEXT,
        start INTEGER NOT NULL,
        end INTEGER,
        notes TEXT NOT NULL DEFAULT '',
        deleted INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (user, id)
      )
      """
    query! """
      CREATE TABLE IF NOT EXISTS session_tags (
        user TEXT NOT NULL,
        session_id TEXT NOT NULL,
        tag TEXT NOT NULL,
        FOREIGN KEY (user, session_id) REFERENCES sessions (user, id)
      )
      """
  end

  def query!(sql, opts \\ []) do
    {:ok, result} = Sqlitex.Server.query __MODULE__, sql, opts
    result
  end
end
