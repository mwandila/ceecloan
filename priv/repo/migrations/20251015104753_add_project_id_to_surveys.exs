defmodule Ceec.Repo.Migrations.AddProjectIdToSurveys do
  use Ecto.Migration

  def change do
    alter table(:surveys) do
      add :project_id, references(:projects, on_delete: :delete_all)
    end
    
    create index(:surveys, [:project_id])
  end
end
