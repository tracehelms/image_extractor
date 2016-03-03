defmodule ImageExtractor.ExtractorTest do
  use ImageExtractor.ModelCase
  alias ImageExtractor.Extractor

  setup do
    valid_urls = [
      ~s{<img href="https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png>},
      ~s{<img href="http://fillmurray.com/200/200.jpg" alt="Mr. Murray">},
      ~s{<img href="http://placecage.com/200/200.gif" alt="Mr. Cage">}
    ]
    invalid_urls = [
      ~s{<img href="http://fillmurray.com/200/200" alt="Mr. Murray">}
    ]

    {:ok, valid_urls: valid_urls, invalid_urls: invalid_urls}
  end

  test "extract_image_tags will find a single image tag", %{valid_urls: valid_urls} do
    html = "<div>#{Enum.at(valid_urls, 0)}</div>"
    assert Extractor.extract_image_tags(html) == [Enum.at(valid_urls, 0)]
  end

  test "extract_image_tags will find a multiple image tags", %{valid_urls: valid_urls} do
    html = "<div>#{List.to_string(valid_urls)}</div>"
    assert Extractor.extract_image_tags(html) == valid_urls
  end

  test "extract_image_tags only gives back images with filetype gif, jpg, or png", %{valid_urls: valid_urls, invalid_urls: invalid_urls} do
    html = "<div>#{List.to_string(valid_urls)}#{List.to_string(invalid_urls)}</div>"
    assert Extractor.extract_image_tags(html) == valid_urls
  end

  test "update_site updates the given Site to set status completed" do
    {_, site} = load_job_and_site
    {:ok, _} = Extractor.update_site(["<img src=\"\">"], site.id)

    site = Repo.get!(ImageExtractor.Site, site.id)
    assert site.status == "completed"
    assert site.images == ["<img src=\"\">"]
  end

  test "full integration of Extractor via start/1" do
    {_, site} = load_job_and_site
    {:ok, _} = Extractor.start(site.id)
    site = Repo.get!(ImageExtractor.Site, site.id)

    assert site.status == "completed"
    assert site.images == [
      ~s{<img href="http://fillmurray.com/200/200.jpg" alt="Mr. Murray">},
      ~s{<img href="http://fillmurray.com/200/200.jpg" alt="Mr. Murray">}
    ]
  end

  defp load_job_and_site do
    {:ok, job} = Repo.insert(%ImageExtractor.Job{})
    {:ok, site} = Repo.insert(%ImageExtractor.Site{
      job_id: job.id,
      url: "http://google.com/images/warning.png",
      status: "inprogress"
    })

    {job, site}
  end

end
