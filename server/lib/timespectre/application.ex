defmodule Timespectre.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    port = case Integer.parse(System.get_env("TIMESPECTRE_PORT")) do
      {port, _} -> port
      :error -> 80
    end

    children = [
      worker(Sqlitex.Server, ["test.db", [name: Timespectre.DB]]),
      Plug.Cowboy.child_spec(scheme: :http, plug: Timespectre.Plug, port: port)
    ]

    IO.puts("Listening on http://localhost:#{port}/index.html")

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Timespectre.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
