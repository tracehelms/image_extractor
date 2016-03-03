defmodule ImageExtractor.JobsController do
  use ImageExtractor.Web, :controller
  alias ImageExtractor.Job
  alias ImageExtractor.Site

  def create(conn, params = %{"urls" => urls}) do
    {:ok, job} = Repo.insert(%Job{})

    Enum.each(urls, fn(url) ->
      Repo.insert(%Site{url: url, job_id: job.id, status: "inprogress"})
    end)

    conn
    |> put_status(202)
    |> json(%{id: job.id})
  end

  def status(conn, %{"id" => id}) do
    job = Repo.get!(Job, id) |> Repo.preload([:sites])

    resp = %{
      id: job.id,
      status: %{
        completed: Enum.count(job.sites, fn(site) -> site.status == "completed" end),
        inprogress: Enum.count(job.sites, fn(site) -> site.status == "inprogress" end)
      }
    }

    conn
    |> put_status(200)
    |> json(resp)
  end

end
