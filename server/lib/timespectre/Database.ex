defmodule Timespectre.Database do
  def child_spec(args) do
    %{
      id: Timespectre.Database,
      start: {Timespectre.Database, :start_link, args}
    }
  end

  def start_link(path) do
    result = Sqlitex.Server.start_link(path, name: __MODULE__)
    initialize_tables()
    result
  end

  defp initialize_tables() do
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
  end

  def query!(sql, opts \\ []) do
    {:ok, result} = Sqlitex.Server.query __MODULE__, sql, opts
    result
  end
end
