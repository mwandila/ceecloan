defmodule Ceec.Repo.Migrations.AddProjectRelationshipToLoans do
  use Ecto.Migration

  def change do
    alter table(:loans) do
      add :project_id, references(:projects, on_delete: :nilify_all)
      add :loan_type, :string
    end
    
    create index(:loans, [:project_id])
    create index(:loans, [:loan_type])
  end
end
