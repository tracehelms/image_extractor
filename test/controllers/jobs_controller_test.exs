defmodule ImageExtractor.JobsControllerTest do
  use ImageExtractor.ConnCase

  test "adding urls to be crawled", %{conn: conn} do
    conn = post(conn, "/api/jobs", %{urls: ["https://google.com"]})
    resp = json_response(conn, 202)

    job = List.last(Repo.all(ImageExtractor.Job))
    assert resp == %{"id" => job.id}
  end

  test "checking status of a job", %{conn: conn} do
    {:ok, job} = ImageExtractor.Repo.insert(%ImageExtractor.Job{})

    {:ok, site} = ImageExtractor.Repo.insert(%ImageExtractor.Site{
      job_id: job.id,
      url: "http://google.com/images/warning.png",
      status: "inprogress"
    })

    conn = get(conn, "/api/jobs/#{job.id}/status")
    resp = json_response(conn, 200)

    assert resp == %{
      "id" => job.id,
      "status" => %{
        "completed" => 0,
        "inprogress" => 1
      }
    }
  end
end
