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
    {:ok, pid} = Agent.start_link(fn () -> 0 end)
    pid
  end

  get "/api/counter" do
    counter = Agent.get(opts, fn x -> x end)
    send_resp(conn, 200, to_string(counter))
  end

  post "/api/counter/increment" do
    Agent.update(opts, fn x -> x + 1 end)
    send_resp(conn, 200, "")
  end

  post "/api/counter/decrement" do
    Agent.update(opts, fn x -> x - 1 end)
    send_resp(conn, 200, "")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end

