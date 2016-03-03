defmodule ImageExtractor.Site do
  use ImageExtractor.Web, :model

  @derive {Poison.Encoder, only: [:url, :images]}
  schema "sites" do
    field :status, :string
    field :images, {:array, :string}
    field :url, :string
    belongs_to :job, ImageExtractor.Job

    timestamps
  end

  @required_fields ~w(status images url)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
