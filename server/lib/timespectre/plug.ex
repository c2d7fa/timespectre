defmodule Timespectre.Plug do
  use Plug.Router

  plug Plug.Logger
  plug :match
  plug Plug.Static, at: "/", from: "../dist/"
  plug Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason
  # Apparently, passing in builder_opts() here lets us set the options in the
  # init function.
  plug :dispatch, builder_opts()

  def init(_opts) do
    Sqlitex.with_db("test.db", fn db ->
      # This query may fail. If it does, it probably means that we already
      # intiailized the database, so we just ignore this case.
      Sqlitex.query db, """
        CREATE TABLE sessions (
          id TEXT PRIMARY KEY,
          start INTEGER NOT NULL,
          end INTEGER NOT NULL,
          notes TEXT NOT NULL DEFAULT '',
          deleted INTEGER DEFAULT 0
        )
        """
    end)
    nil
  end

  put "/api/sessions/:id" do
    start_time = conn.body_params["start"]
    end_time = conn.body_params["end"]
    query! "INSERT INTO sessions (id, start, end) VALUES (?1, ?2, ?3)", bind: [id, start_time, end_time]
    send_resp(conn, 200, "")
  end

  put "/api/sessions/:id/notes" do
    notes = conn.body_params["_json"]
    query! "UPDATE sessions SET notes = ?2 WHERE id = ?1", bind: [id, notes]
    send_resp(conn, 200, "")
  end

  delete "/api/sessions/:id" do
    query! "UPDATE sessions SET deleted = 1 WHERE id = ?1", bind: [id]
    send_resp(conn, 200, "")
  end

  get "/api/sessions" do
    sessions = query! "SELECT * FROM sessions WHERE deleted = 0 ORDER BY end DESC", into: %{}
    send_resp(conn, 200, Jason.encode! sessions)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  defp query!(sql, opts \\ []) do
    {:ok, result} = Sqlitex.Server.query(Timespectre.DB, sql, opts)
    result
  end
end

