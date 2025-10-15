defmodule Ceec.Repo.Migrations.UpdateSurveyResponsesForLoans do
  use Ecto.Migration

  def change do
    alter table(:survey_responses) do
      add_if_not_exists :loan_id, references(:loans, on_delete: :delete_all)
      add_if_not_exists :user_id, references(:users, on_delete: :delete_all)
      add_if_not_exists :completion_status, :string, default: "in_progress" # in_progress, completed, abandoned
      add_if_not_exists :submitted_at, :utc_datetime
      add_if_not_exists :ip_address, :string
      add_if_not_exists :user_agent, :text
    end

    create_if_not_exists index(:survey_responses, [:loan_id])
    create_if_not_exists index(:survey_responses, [:user_id])
    create_if_not_exists index(:survey_responses, [:completion_status])
    create_if_not_exists index(:survey_responses, [:submitted_at])
  end
end
