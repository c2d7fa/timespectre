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

    # [TODO] I'm not very familiar with Elixir, but I don't this this should
    # just be sitting here. Don't we want this inside a supervisor or something?
    # Also, I'm not sure if I'm using 'start_link' ideomatically here.
    Timespectre.Database.start_link(db_path, name: Timespectre.Database)

    children = [
      {Plug.Cowboy, scheme: :http, plug: Timespectre.Plug, port: port}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
