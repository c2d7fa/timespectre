defmodule Timespectre.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    {port, _} = Integer.parse(System.get_env("TIMESPECTRE_PORT") || "80")

    db_path = System.get_env("TIMESPECTRE_DATABASE_PATH") || "/var/lib/timespectre/data.db"

    db_dir = Path.dirname(db_path)
    if !File.dir?(db_dir) do
      File.mkdir!(db_dir)
    end

    IO.puts("Listening on http://localhost:#{port}/index.html")

    children = [
      {Timespectre.Database, [db_path]},
      {Plug.Cowboy, scheme: :http, plug: Timespectre.Plug, port: port}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
