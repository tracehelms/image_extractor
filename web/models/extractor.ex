defmodule ImageExtractor.Extractor do

  def start_crawl(url, site_id, level) do
    if Mix.env == :test do
      crawl(url, site_id, level)
      :ok
    else
      spawn ImageExtractor.Extractor, :crawl, [url, site_id, level]
    end
  end

  def crawl(url, site_id, level) do
    content = get_html!(url)

    content
    |> extract_image_tags
    |> extract_urls
    |> update_site(site_id)

    content
    |> extract_anchor_tags(url)
    |> extract_urls
    |> launch_child_jobs(site_id, level + 1)
  end

  def get_html!(url) do
    HTTPotion.get(url).body
  end

  def extract_image_tags(content) do
    Regex.scan(~r{<img.*src=.*>}r, content)
    |> List.flatten
    |> Enum.filter( &String.match?(&1, ~r{\.(jpg|png|gif)}) )
  end

  def extract_anchor_tags(content, base_url) do
    Regex.scan(~r{<a.*href=.*>}r, content)
    |> List.flatten
    |> Enum.filter( &String.contains?(&1, base_url))
  end

  def extract_urls(tag_list) do
    output = Enum.map(tag_list, fn(tag) ->
      Regex.split(~r{(src="|href=")}r, tag)
      |> Enum.at(1)
      |> String.split("\"")
      |> Enum.at(0)
    end)
    |> List.flatten
  end

  def update_site([], _), do: nil
  def update_site(images, site_id) do
    site = ImageExtractor.Repo.get!(ImageExtractor.Site, site_id)

    site
    |> ImageExtractor.Site.changeset(%{images: site.images ++ images})
    |> ImageExtractor.Repo.update
  end

  # this finishes off the process and marks the site status as "complete"
  def launch_child_jobs(_content, site_id, level) when level >= 1 do
    ImageExtractor.Repo.get!(ImageExtractor.Site, site_id)
    |> ImageExtractor.Site.changeset(%{status: "completed"})
    |> ImageExtractor.Repo.update
  end

  def launch_child_jobs(urls, site_id, level) do
    urls
    |> Enum.each(fn(url) -> start_crawl(url, site_id, level) end)
  end

end
