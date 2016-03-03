defmodule ImageExtractor.Job do
  use ImageExtractor.Web, :model

  @derive {Poison.Encoder, only: [:id, :sites]}
  schema "jobs" do
    has_many :sites, ImageExtractor.Site

    timestamps
  end

  @required_fields ~w()
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
