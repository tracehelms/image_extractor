defmodule ImageExtractor.Extractor do

  # def start(urls, job_id) do
  #   Enum.each(urls, fn(url) -> crawl(url, job_id, 0) end)
  # end

  # def crawl(url, job_id, level) when level <= 1 do
  #   html_content = HTTPotion.get(url)
  #
  #   html_content
  #   |> extract_image_tags
  #   |> update_job
  #
  #   html_content
  #   |> extract_anchor_tags
  #   |> filter
  #   |> Enum.each(&crawl(&1, job_id, level++))
  # end

  def extract_image_tags(body) do
    Regex.scan(~r{<img.*>}r, body)
    |> List.flatten
    |> Enum.filter( &String.match?(&1, ~r{\.(jpg|png|gif)}) )
  end

end
