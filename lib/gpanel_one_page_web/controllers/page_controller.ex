defmodule GpanelOnePageWeb.PageController do
  use GpanelOnePageWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def not_found(conn, _params) do
    conn
    |> put_status(404)
    |> redirect(to: "/404.html")
  end
end
