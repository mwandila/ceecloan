defmodule Ceec.Repo.Migrations.CreateLoans do
  use Ecto.Migration

  def change do
    create table(:loans) do
      add :loan_id, :string
      add :project_name, :string
      add :amount, :decimal
      add :interest_rate, :decimal
      add :maturity_date, :date
      add :status, :string
      add :created_by, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:loans, [:loan_id])
  end
end
