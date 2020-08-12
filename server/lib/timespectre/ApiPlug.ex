defmodule Timespectre.ApiPlug do
  import Timespectre.Database, only: [{:query!, 2}]

  use Plug.Router

  plug Timespectre.AuthenticationPlug
  plug :match
  plug Plug.Parsers, parsers: [:json], pass: [], json_decoder: Jason
  plug :dispatch

  forward "/stats", to: Timespectre.StatsPlug

  defmacrop authenticated_user do
    quote do
      var!(conn).assigns[:authenticated_user]
    end
  end

  put "/sessions/:id" do
    start_time = conn.body_params["start"]
    end_time = conn.body_params["end"]
    query! "INSERT INTO sessions (user, id, start, end) VALUES (?1, ?2, ?3, ?4)", bind: [authenticated_user(), id, start_time, end_time]
    send_resp(conn, 200, "")
  end

  put "/sessions/:id/end" do
    end_time = conn.body_params["_json"]
     query! "UPDATE sessions SET end = ?3 WHERE user = ?1 AND id = ?2", bind: [authenticated_user(), id, end_time]
    send_resp(conn, 200, "")
  end

  put "/sessions/:id/notes" do
    notes = conn.body_params["_json"]
    query! "UPDATE sessions SET notes = ?3 WHERE user = ?1 AND id = ?2", bind: [authenticated_user(), id, notes]
    send_resp(conn, 200, "")
  end

  delete "/sessions/:id" do
    query! "UPDATE sessions SET deleted = 1 WHERE user = ?1 AND id = ?2", bind: [authenticated_user(), id]
    send_resp(conn, 200, "")
  end

  get "/sessions" do
    sessions = query! """
      SELECT
        id, start, end, notes,
        IFNULL(GROUP_CONCAT(tag), '') AS tags
      FROM sessions
      LEFT JOIN session_tags ON sessions.user = session_tags.user AND id = session_id
      WHERE sessions.user = ?1 AND NOT deleted
      GROUP BY id
      ORDER BY end IS NOT NULL, end DESC, start DESC
      LIMIT 50
      """, bind: [authenticated_user()]

    split_comma_list = fn s ->
      String.split(s, ",") |> Enum.filter(fn x -> x != "" end)
    end

    result = Enum.map(sessions, fn session ->
      session
        |> Map.new
        |> Map.put(:tags, split_comma_list.(Keyword.get(session, :tags)))
    end)

    send_resp(conn, 200, Jason.encode! result)
  end

  # Rename or create tag
  post "/sessions/:id/tags/:tag" do
    new_tag = conn.body_params["_json"]
    query! ~s{DELETE FROM session_tags WHERE user = ?1 AND session_id = ?2 AND tag = ?3}, bind: [authenticated_user(), id, tag]
    query! ~s{INSERT OR IGNORE INTO session_tags (user, session_id, tag) VALUES (?1, ?2, ?3)}, bind: [authenticated_user(), id, new_tag]
    send_resp(conn, 200, "")
  end

  delete "/sessions/:id/tags/:tag" do
    query! ~s{DELETE FROM session_tags WHERE user = ?1 AND session_id = ?2 AND tag = ?3}, bind: [authenticated_user(), id, tag]
    send_resp(conn, 200, "")
  end

  match _ do
    send_resp(conn, 404, "No such API endpoint exists.")
  end
end