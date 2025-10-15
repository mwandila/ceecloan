defmodule Ceec.Repo.Migrations.AddPublicApplicationFieldsToLoans do
  use Ecto.Migration

  def change do
    alter table(:loans) do
      # Public loan application fields
      add :applicant_name, :string
      add :first_name, :string
      add :last_name, :string
      add :business_name, :string
      add :phone, :string
      add :email, :string
      add :nrc, :string
      add :business_type, :string
      add :years_in_business, :integer
      add :purpose, :text
      add :province, :string
      add :district, :string
      add :constituency, :string
      add :rejection_reason, :text
      add :disbursed_at, :utc_datetime
    end
  end
end
