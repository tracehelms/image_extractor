defmodule ImageExtractor.Extractor do

  def start(site_id) do
    site = ImageExtractor.Repo.get!(ImageExtractor.Site, site_id)
    site.url
    |> get_html!
    |> extract_image_tags
    |> update_site(site.id)
  end

  def get_html!(url) do
    HTTPotion.get(url).body
  end

  def extract_image_tags(content) do
    Regex.scan(~r{<img.*>}r, content)
    |> List.flatten
    |> Enum.filter( &String.match?(&1, ~r{\.(jpg|png|gif)}) )
  end

  def update_site(images, site_id) do
    ImageExtractor.Repo.get!(ImageExtractor.Site, site_id)
    |> ImageExtractor.Site.changeset(%{status: "completed", images: images})
    |> ImageExtractor.Repo.update
  end
end
