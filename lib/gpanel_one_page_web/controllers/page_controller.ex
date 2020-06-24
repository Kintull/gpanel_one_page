defmodule GpanelOnePageWeb.PageController do
  use GpanelOnePageWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
