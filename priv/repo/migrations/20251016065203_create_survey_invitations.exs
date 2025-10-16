defmodule Ceec.Repo.Migrations.CreateSurveyInvitations do
  use Ecto.Migration

  def change do
    create table(:survey_invitations) do
      add :survey_id, references(:surveys, on_delete: :delete_all), null: false
      add :loan_id, references(:loans, on_delete: :delete_all), null: false
      add :project_id, references(:projects, on_delete: :delete_all), null: false
      add :recipient_name, :string, null: false
      add :recipient_email, :string
      add :recipient_phone, :string
      add :status, :string, default: "pending", null: false # pending, completed, expired
      add :invited_at, :utc_datetime, null: false
      add :completed_at, :utc_datetime
      add :unique_token, :string, null: false
      add :expires_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:survey_invitations, [:survey_id, :loan_id])
    create unique_index(:survey_invitations, :unique_token)
    create index(:survey_invitations, :survey_id)
    create index(:survey_invitations, :project_id)
    create index(:survey_invitations, :status)
  end
end
