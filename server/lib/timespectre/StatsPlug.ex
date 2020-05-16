defmodule Timespectre.StatsPlug do
  import Timespectre.Database, only: [{:query!, 2}, {:query!, 1}]

  use Plug.Router

  plug :match
  plug :dispatch

  get "/tags" do
    since = case conn.query_params["since"] do
      nil -> 0
      since_string ->
        case Integer.parse(since_string) do
          {since_int, ""} -> since_int
          _ -> 0
        end
    end

    result = query! """
      SELECT tag, SUM(end - start) as duration
      FROM session_tags
      JOIN sessions ON id = session_id
      WHERE
        NOT deleted
        AND end >= ?1
      GROUP BY tag
      """, bind: [since]

    map = Map.new result, fn [tag: tag, duration: duration] -> {tag, duration || 0} end

    send_resp(conn, 200, Jason.encode! map)
  end

  match _ do
    send_resp(conn, 404, "No such API stats endpoint exists.")
  end
end
