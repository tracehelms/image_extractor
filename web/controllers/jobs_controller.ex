defmodule ImageExtractor.JobsController do
  use ImageExtractor.Web, :controller

  def create(conn, params = %{"urls" => urls}) do
    conn
    |> put_status(202)
    |> json(%{urls: urls})
  end
end
