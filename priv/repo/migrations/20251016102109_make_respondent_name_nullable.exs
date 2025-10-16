defmodule Ceec.Repo.Migrations.MakeRespondentNameNullable do
  use Ecto.Migration

  def change do
    # Make respondent_name nullable to support dynamic survey responses
    # that don't require all the legacy survey form fields
    alter table(:survey_responses) do
      modify :respondent_name, :string, null: true
    end
  end
end
