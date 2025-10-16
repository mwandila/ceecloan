defmodule Ceec.Surveys.SurveyInvitation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "survey_invitations" do
    field :recipient_name, :string
    field :recipient_email, :string
    field :recipient_phone, :string
    field :status, :string, default: "pending"
    field :invited_at, :utc_datetime
    field :completed_at, :utc_datetime
    field :unique_token, :string
    field :expires_at, :utc_datetime

    belongs_to :survey, Ceec.Surveys.Survey
    belongs_to :loan, Ceec.Finance.Loan
    belongs_to :project, Ceec.Projects.Project

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(survey_invitation, attrs) do
    survey_invitation
    |> cast(attrs, [
      :survey_id, :loan_id, :project_id, :recipient_name, :recipient_email, 
      :recipient_phone, :status, :invited_at, :completed_at, :unique_token, :expires_at
    ])
    |> validate_required([:survey_id, :loan_id, :project_id, :recipient_name, :invited_at, :unique_token])
    |> validate_inclusion(:status, ["pending", "completed", "expired"])
    |> unique_constraint([:survey_id, :loan_id])
    |> unique_constraint(:unique_token)
    |> foreign_key_constraint(:survey_id)
    |> foreign_key_constraint(:loan_id)
    |> foreign_key_constraint(:project_id)
  end

  @doc """
  Generate a unique token for survey invitation
  """
  def generate_token do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
  end

  @doc """
  Set expiration date (default 30 days from now)
  """
  def set_expiration(changeset, days \\ 30) do
    expires_at = DateTime.utc_now() |> DateTime.add(days * 24 * 60 * 60, :second)
    put_change(changeset, :expires_at, expires_at)
  end
end