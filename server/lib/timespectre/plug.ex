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
      # These queries may fail. However, if they do, it probably means that we
      # already intiailized the database, so we just ignore the errors.
      Sqlitex.query db, """
        CREATE TABLE sessions (
          id TEXT PRIMARY KEY,
          start INTEGER NOT NULL,
          end INTEGER,
          notes TEXT NOT NULL DEFAULT '',
          deleted INTEGER DEFAULT 0
        )
        """
      Sqlitex.query db, """
        CREATE TABLE session_tags (
          session_id TEXT REFERENCES sessions(id),
          tag TEXT NOT NULL,
          PRIMARY KEY (session_id, tag)
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

  put "/api/sessions/:id/end" do
    end_time = conn.body_params["_json"]
    query! "UPDATE sessions SET end = ?2 WHERE id = ?1", bind: [id, end_time]
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
    # [TODO] Don't query unnecessary session tags.

    sessions = query! ~s{SELECT "id", "start", "end", "notes" FROM "sessions" WHERE "deleted" = 0 ORDER BY "end" IS NOT NULL, "end" DESC, "start" DESC}, into: %{}
    session_tags = query! ~s{SELECT "session_id", "tag" FROM "session_tags"}, into: %{}

    sessions_with_tags = Enum.map(sessions, fn session ->
      tags = session_tags
        |> Enum.filter(fn tag -> tag.session_id == session.id end)
        |> Enum.map(fn tag -> tag.tag end)
      Map.put_new(session, :tags, tags)
    end)

    send_resp(conn, 200, Jason.encode! sessions_with_tags)
  end

  # Rename or create tag
  post "/api/sessions/:id/tags/:tag" do
    new_tag = conn.body_params["_json"]
    query! ~s{DELETE FROM "session_tags" WHERE "session_id" = ?1 AND "tag" = ?2}, bind: [id, tag]
    query! ~s{INSERT OR IGNORE INTO "session_tags"("session_id", "tag") VALUES (?1, ?2)}, bind: [id, new_tag]
    send_resp(conn, 200, "")
  end

  delete "/api/sessions/:id/tags/:tag" do
    query! ~s{DELETE FROM "session_tags" WHERE "session_id" = ?1 AND "tag" = ?2}, bind: [id, tag]
    send_resp(conn, 200, "")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  defp query!(sql, opts \\ []) do
    {:ok, result} = Sqlitex.Server.query(Timespectre.DB, sql, opts)
    result
  end
end

