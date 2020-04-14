defmodule Timespectre.Plug do
  use Plug.Router

  plug :match
  plug Plug.Static, at: "/", from: "../dist/"

  # We want to store the counter as state. We can use Agents to store state. We
  # need to make the agent's PID available to each route. We can do this by
  # passing it in as an option. Apparently, passing in builder_opts() here let's
  # us set the options in the init function.
  plug :dispatch, builder_opts()

  def init(_opts) do
    Sqlitex.with_db("test.db", fn db ->
      Sqlitex.query db, "CREATE TABLE counters (user TEXT PRIMARY KEY, counter INTEGER)"
      Sqlitex.query db, "INSERT INTO counters (user, counter) VALUES ('global', 0)"
    end)
    nil
  end

  get "/api/counter" do
    [[counter: counter]] = Sqlitex.with_db("test.db", &Sqlitex.query!(&1, "SELECT counter FROM counters WHERE user = 'global'") )
    send_resp(conn, 200, to_string(counter))
  end

  post "/api/counter/increment" do
    Sqlitex.with_db("test.db", fn db ->
      Sqlitex.query! db, "BEGIN"
      [[counter: counter]] = Sqlitex.query! db, "SELECT counter FROM counters WHERE user = 'global'"
      Sqlitex.query! db, "UPDATE counters SET counter = ?1 WHERE user = 'global'", bind: [counter + 1]
      Sqlitex.query! db, "COMMIT"
    end)
    send_resp(conn, 200, "")
  end

  post "/api/counter/decrement" do
    Sqlitex.with_db("test.db", fn db ->
      Sqlitex.query! db, "BEGIN"
      [[counter: counter]] = Sqlitex.query! db, "SELECT counter FROM counters WHERE user = 'global'"
      Sqlitex.query! db, "UPDATE counters SET counter = ?1 WHERE user = 'global'", bind: [counter - 1]
      Sqlitex.query! db, "COMMIT"
    end)
    send_resp(conn, 200, "")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end

