defmodule ImageExtractor.Repo.Migrations.CreateSite do
  use Ecto.Migration

  def change do
    create table(:sites) do
      add :status, :string
      add :images, {:array, :text}
      add :url, :text
      add :job_id, references(:jobs, on_delete: :delete_all)

      timestamps
    end
    create index(:sites, [:job_id])

  end
end
