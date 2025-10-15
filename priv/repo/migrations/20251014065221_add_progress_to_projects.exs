defmodule Ceec.Repo.Migrations.AddProgressToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :progress, :integer, default: 0
      add :project_id, :string
    end

    create index(:projects, [:project_id])
  end
end
