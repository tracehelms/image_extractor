defmodule ImageExtractor.Extractor do

  def start(site_id) do
    site = ImageExtractor.Repo.get!(ImageExtractor.Site, site_id)
    site.url
    |> crawl(0)
    |> extract_image_tags
    |> update_site(site.id)
  end

  def update_site(images, site_id) do
    ImageExtractor.Repo.get!(ImageExtractor.Site, site_id)
    |> ImageExtractor.Site.changeset(%{status: "completed", images: images})
    |> ImageExtractor.Repo.update
  end

  def crawl(_, level) when level > 1, do: ""
  def crawl(url, level) do
    # TODO pseudo-code
    # html_content = HTTPotion.get(url)
    #
    # html_content
    # |> extract_image_tags
    # |> update_job
    #
    # html_content
    # |> extract_anchor_tags
    # |> filter
    # |> Enum.each(&crawl(&1, job_id, level++))
    ~s{<div><img href="http://fillmurray.com/200/200.jpg" alt="Mr. Murray"></div>} <> crawl(url, level+1)
  end

  def extract_image_tags(body) do
    Regex.scan(~r{<img.*>}r, body)
    |> List.flatten
    |> Enum.filter( &String.match?(&1, ~r{\.(jpg|png|gif)}) )
  end

end
