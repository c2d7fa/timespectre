defmodule Timespectre.Plug do
  use Plug.Builder

  plug Plug.Static, at: "/", from: "../dist/"
  plug :not_found

  def not_found(conn, _opts) do
    conn |> send_resp(404, "Not found")
  end
end

