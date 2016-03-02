defmodule ImageExtractor.PageController do
  use ImageExtractor.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
