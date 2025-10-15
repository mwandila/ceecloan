defmodule Ceec.Repo.Migrations.AddBorrowerToLoans do
  use Ecto.Migration

  def change do
    alter table(:loans) do
      add :borrower_id, references(:users, on_delete: :delete_all), null: true
    end
    
    create index(:loans, [:borrower_id])
  end
end
