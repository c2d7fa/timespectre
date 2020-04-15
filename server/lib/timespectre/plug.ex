defmodule Timespectre.Plug do
  use Plug.Router

  plug Plug.Logger
  plug :match
  plug Plug.Static, at: "/", from: "../dist/"
  # Apparently, passing in builder_opts() here lets us set the options in the
  # init function.
  plug :dispatch, builder_opts()

  def init(_opts) do
    Sqlitex.with_db("test.db", fn db ->
      # May fail. If they do, it means that we probably already initialized the
      # database.
      Sqlitex.query db, "CREATE TABLE counters (user TEXT PRIMARY KEY, counter INTEGER)"
      Sqlitex.query db, "INSERT INTO counters (user, counter) VALUES ('global', 0)"
    end)
    nil
  end

  get "/api/counter" do
    [[counter: counter]] = query! "SELECT counter FROM counters WHERE user = 'global'"
    send_resp(conn, 200, to_string(counter))
  end

  post "/api/counter/increment" do
    query! "UPDATE counters SET counter = counter + 1 WHERE user = 'global'"
    send_resp(conn, 200, "")
  end

  post "/api/counter/decrement" do
    query! "UPDATE counters SET counter = counter - 1 WHERE user = 'global'"
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

