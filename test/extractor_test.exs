defmodule ImageExtractor.ExtractorTest do
  use ImageExtractor.ModelCase
  alias ImageExtractor.Extractor
  use ExVCR.Mock

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    :ok
  end

  test "get_html! gets html content from the given url" do
    use_cassette "get_html! happy test" do
      body = Extractor.get_html!("https://www.google.com")
      assert body =~ ~r{Google Search}
      assert body =~ ~r{I'm Feeling Lucky}
    end
  end

  test "extract_image_tags will find a single image tag" do
    img_tag = ~s{<img src="http://test.com/test.png" alt="Test image">}
    html = "<div>#{img_tag}</div>"
    assert Extractor.extract_image_tags(html) == [img_tag]
  end

  test "extract_image_tags will find a multiple image tags" do
    img_tags = [
      ~s{<img src="http://test.com/test.png" alt="Test image">},
      ~s{<img src="http://example.com/example.png" alt="Example image">}
    ]
    html = "<div>#{List.to_string(img_tags)}</div>"
    assert Extractor.extract_image_tags(html) == img_tags
  end

  test "extract_image_tags only gives back images with filetype gif, jpg, or png" do
    img_tags = [
      ~s{<img src="http://test.com/test" alt="Bad image">},
      ~s{<img src="http://example.com/example.png" alt="Example image">}
    ]
    html = "<div>#{List.to_string(img_tags)}</div>"
    assert Extractor.extract_image_tags(html) == [Enum.at(img_tags, 1)]
  end

  test "extract_anchor_tags gets anchor tags from html" do
    a_tags = [
      ~s{<a href="http://test.com">},
      ~s{<a href="http://test.com/test_page.html">}
    ]
    html = "<div>#{a_tags}</div>"
    assert Extractor.extract_anchor_tags(html, "http://test.com") == a_tags
  end

  test "extract_anchor_tags only includes child pages on same domain" do
    a_tags = [
      ~s{<a href="http://test.com/test_page">},
      ~s{<a href="http://example.com">}
    ]
    html = "<div>#{a_tags}</div>"
    assert Extractor.extract_anchor_tags(html, "http://test.com") == [Enum.at(a_tags, 0)]
  end

  test "extract_urls gets urls from images and anchor tags" do
    tags = [
      ~s{<img src="http://test.com/test.png" alt="Test image">},
      ~s{<a href="http://example.com/example_page">},
      ~s{<img src="/images/example.jpg">}
    ]

    assert Extractor.extract_urls(tags) == [
      ~s{http://test.com/test.png},
      ~s{http://example.com/example_page},
      ~s{/images/example.jpg}
    ]
  end

  test "qualify_urls qualifies relative URLs and leaves qualified ones alone" do
    image_urls = [
      ~s{http://test.com/test.png},
      ~s{/images/example_image.gif}
    ]

    assert Extractor.qualify_urls(image_urls, "http://example.com") == [
      ~s{http://test.com/test.png},
      ~s{http://example.com/images/example_image.gif}
    ]
  end

  test "update_site only adds urls to the given site" do
    {_job, site, _url} = load_job_and_site
    images = ["http://example.com/example.jpg"]
    original_images = site.images

    {:ok, _} = Extractor.update_site(images, site.id)

    site = Repo.get!(ImageExtractor.Site, site.id)
    assert site.images == original_images ++ images
  end

  test "trying to launch child jobs when at last level sets site status to completed" do
    {_job, site, _url} = load_job_and_site
    Extractor.launch_child_jobs(["http://google.com"], site.id, 2)

    site = Repo.get!(ImageExtractor.Site, site.id)
    assert site.status == "completed"
  end

  test "full integration of Extractor via start_crawl" do
    use_cassette "crawl integration happy test" do
      {_job, site, url} = load_job_and_site
      Extractor.start_crawl(url, site.id, 0)

      site = Repo.get!(ImageExtractor.Site, site.id)

      assert site.status == "completed"
      assert site.images == [
        "http://test.com/test.png",
        "https://www.google.com/images/icons/product/chrome-48.png",
        "https://www.google.com/images/branding/googlelogo/1x/googlelogo_white_background_color_272x92dp.png",
        "https://www.google.com/finance/f/logo_us-115376669.gif"
      ]
    end
  end

  test "full integration of empty page" do
    use_cassette "crawl integration empty page test" do
      {_job, site, url} = load_job_and_site("https://scraper.ngrok.io/basic0.html")
      Extractor.start_crawl(url, site.id, 0)

      site = Repo.get!(ImageExtractor.Site, site.id)

      assert site.status == "completed"
      assert site.images == [
        "http://test.com/test.png"
      ]
    end
  end

  defp load_job_and_site(url \\ "https://www.google.com") do
    url = url
    {:ok, job} = Repo.insert(%ImageExtractor.Job{})
    {:ok, site} = Repo.insert(%ImageExtractor.Site{
      job_id: job.id,
      url: url,
      status: "inprogress",
      images: ["http://test.com/test.png"]
    })

    {job, site, url}
  end

end
