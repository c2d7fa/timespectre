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
          CREATE TABLE tags (
            id TEXT PRIMARY KEY,
            label TEXT NOT NULL
          )
        """
        Sqlitex.query db, """
          CREATE TABLE session_tags (
            session_id TEXT REFERENCES tags(id),
            tag_id TEXT REFERENCES sessions(id),
            PRIMARY KEY (session_id, tag_id)
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

  get "/api/state" do
    # [TODO] Don't query unnecessary session tags or tags.

    tags = query! ~s{SELECT * FROM "tags"}, into: %{}
    sessions = query! ~s{SELECT * FROM "sessions" WHERE "deleted" = 0 ORDER BY "end" IS NOT NULL, "end" DESC, "start" DESC}, into: %{}
    session_tags = query! ~s{SELECT * FROM "session_tags"}, into: %{}

    sessions_with_tags = Enum.map(sessions, fn session ->
      tags = session_tags
        |> Enum.filter(fn tag -> tag.session_id == session.id end)
        |> Enum.map(fn tag -> tag.tag_id end)
      Map.put_new(session, :tags, tags)
    end)

    send_resp(conn, 200, Jason.encode! %{tags: tags, sessions: sessions_with_tags})
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  defp query!(sql, opts \\ []) do
    {:ok, result} = Sqlitex.Server.query(Timespectre.DB, sql, opts)
    result
  end
end

