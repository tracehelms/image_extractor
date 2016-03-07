defmodule ImageExtractor.JobsControllerTest do
  use ImageExtractor.ConnCase
  use ExVCR.Mock

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    :ok
  end

  test "adding urls to be crawled", %{conn: conn} do
    use_cassette "adding urls to be crawled" do
      conn = post(conn, "/jobs", %{urls: ["https://google.com"]})
      resp = json_response(conn, 202)

      job = List.last(Repo.all(ImageExtractor.Job))
      assert resp == %{"id" => job.id}
    end
  end

  test "checking status of a job", %{conn: conn} do
    {:ok, job} = ImageExtractor.Repo.insert(%ImageExtractor.Job{})

    {:ok, _site} = ImageExtractor.Repo.insert(%ImageExtractor.Site{
      job_id: job.id,
      url: "http://google.com/images/warning.png",
      status: "inprogress"
    })

    conn = get(conn, "/jobs/#{job.id}/status")
    resp = json_response(conn, 200)

    assert resp == %{
      "id" => job.id,
      "status" => %{
        "completed" => 0,
        "inprogress" => 1
      }
    }
  end

  test "checking results of a job", %{conn: conn} do
    {:ok, job} = ImageExtractor.Repo.insert(%ImageExtractor.Job{})

    {:ok, _site} = ImageExtractor.Repo.insert(%ImageExtractor.Site{
      job_id: job.id,
      url: "https://www.google.com",
      status: "completed",
      images: ["https://www.google.com/images/warning.png"]
    })

    conn = get(conn, "/jobs/#{job.id}/results")
    resp = json_response(conn, 200)

    assert resp == %{
      "id" => job.id,
      "results" => %{
        "https://www.google.com" => ["https://www.google.com/images/warning.png"]
      }
    }
  end
end
