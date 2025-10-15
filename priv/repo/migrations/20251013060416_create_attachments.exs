defmodule Ceec.Repo.Migrations.CreateAttachments do
  use Ecto.Migration

  def change do
    create table(:attachments) do
      add :filename, :string, null: false
      add :original_filename, :string, null: false
      add :file_path, :string, null: false
      add :file_size, :integer, null: false
      add :content_type, :string, null: false
      add :file_type, :string
      
      # Metadata
      add :description, :text
      add :uploaded_by, :string
      add :uploaded_at, :utc_datetime
      
      # Image-specific fields
      add :image_width, :integer
      add :image_height, :integer
      add :gps_latitude, :decimal, precision: 10, scale: 8
      add :gps_longitude, :decimal, precision: 11, scale: 8
      
      add :form_submission_id, references(:form_submissions, on_delete: :delete_all)
      add :project_id, references(:projects, on_delete: :delete_all)
      add :beneficiary_id, references(:beneficiaries, on_delete: :nilify_all)

      timestamps()
    end

    create index(:attachments, [:form_submission_id])
    create index(:attachments, [:project_id])
    create index(:attachments, [:beneficiary_id])
    create index(:attachments, [:file_type])
    create index(:attachments, [:uploaded_at])
  end
end
