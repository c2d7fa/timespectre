defmodule Timespectre.StatsPlug do
  import Timespectre.Database, only: [{:query!, 2}, {:query!, 1}]

  use Plug.Router

  plug :match
  plug :dispatch

  get "/tags" do
    result = query! """
      SELECT tag, SUM(end - start) as duration
      FROM session_tags
      JOIN sessions ON id = session_id
      WHERE
        NOT deleted
      GROUP BY tag
      """

    map = Map.new result, fn [tag: tag, duration: duration] -> {tag, duration} end

    send_resp(conn, 200, Jason.encode! map)
  end

  match _ do
    send_resp(conn, 404, "No such API stats endpoint exists.")
  end
end
