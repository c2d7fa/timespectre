defmodule Timespectre.ApiPlug do
  import Timespectre.Database, only: [{:query!, 1}, {:query!, 2}]

  use Plug.Router

  plug Timespectre.AuthenticationPlug
  plug :match
  plug Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason
  plug :dispatch

  forward "/stats", to: Timespectre.StatsPlug

  put "/sessions/:id" do
    start_time = conn.body_params["start"]
    end_time = conn.body_params["end"]
    query! "INSERT INTO sessions (id, start, end) VALUES (?1, ?2, ?3)", bind: [id, start_time, end_time]
    send_resp(conn, 200, "")
  end

  put "/sessions/:id/end" do
    end_time = conn.body_params["_json"]
    query! "UPDATE sessions SET end = ?2 WHERE id = ?1", bind: [id, end_time]
    send_resp(conn, 200, "")
  end

  put "/sessions/:id/notes" do
    notes = conn.body_params["_json"]
    query! "UPDATE sessions SET notes = ?2 WHERE id = ?1", bind: [id, notes]
    send_resp(conn, 200, "")
  end

  delete "/sessions/:id" do
    query! "UPDATE sessions SET deleted = 1 WHERE id = ?1", bind: [id]
    send_resp(conn, 200, "")
  end

  get "/sessions" do
    sessions = query! """
      SELECT
        id, start, end, notes,
        IFNULL(GROUP_CONCAT(tag), '') AS tags
      FROM sessions
      LEFT JOIN session_tags ON id = session_id
      WHERE NOT deleted
      GROUP BY id
      ORDER BY end IS NOT NULL, end DESC, start DESC
      LIMIT 50
      """

    result = Enum.map(sessions, fn session ->
      session
        |> Map.new
        |> Map.put(:tags, String.split(Keyword.get(session, :tags), ","))
    end)

    send_resp(conn, 200, Jason.encode! result)
  end

  # Rename or create tag
  post "/sessions/:id/tags/:tag" do
    new_tag = conn.body_params["_json"]
    query! ~s{DELETE FROM "session_tags" WHERE "session_id" = ?1 AND "tag" = ?2}, bind: [id, tag]
    query! ~s{INSERT OR IGNORE INTO "session_tags"("session_id", "tag") VALUES (?1, ?2)}, bind: [id, new_tag]
    send_resp(conn, 200, "")
  end

  delete "/sessions/:id/tags/:tag" do
    query! ~s{DELETE FROM "session_tags" WHERE "session_id" = ?1 AND "tag" = ?2}, bind: [id, tag]
    send_resp(conn, 200, "")
  end

  match _ do
    send_resp(conn, 404, "No such API endpoint exists.")
  end
end