defmodule ImageExtractor.JobsControllerTest do
  use ImageExtractor.ConnCase

  test "adding urls to be crawled", %{conn: conn} do
    conn = post(conn, "/api/jobs", %{urls: ["https://google.com"]})
    resp = json_response(conn, 202)
    assert Map.get(resp, "urls") == ["https://google.com"]
  end
end
