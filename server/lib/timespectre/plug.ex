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
      Sqlitex.query db, "CREATE TABLE sessions (id TEXT PRIMARY KEY, start INTEGER, end INTEGER)"
    end)
    nil
  end

  put "/api/sessions/:id" do
    start_time = conn.body_params["start"]
    end_time = conn.body_params["end"]
    query! "INSERT INTO sessions VALUES (?1, ?2, ?3)", bind: [id, start_time, end_time]
    send_resp(conn, 200, "")
  end

  get "/api/sessions" do
    response = query!("SELECT * FROM sessions")
      |> Enum.map(fn session -> {session[:id], %{:start => session[:start], :end => session[:end]}} end)
      |> Map.new
      |> Jason.encode!
    send_resp(conn, 200, response)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  defp query!(sql, opts \\ []) do
    {:ok, result} = Sqlitex.Server.query(Timespectre.DB, sql, opts)
    result
  end
end

