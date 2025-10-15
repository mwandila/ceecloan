defmodule Ceec.DataCollection.Attachment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "attachments" do
    field :filename, :string
    field :original_filename, :string
    field :file_path, :string
    field :file_size, :integer
    field :content_type, :string
    field :file_type, :string  # "photo", "document", "audio", "video", "other"
    
    # Metadata
    field :description, :string
    field :uploaded_by, :string
    field :uploaded_at, :utc_datetime
    
    # Image-specific fields
    field :image_width, :integer
    field :image_height, :integer
    field :gps_latitude, :decimal
    field :gps_longitude, :decimal
    
    # Relationships
    belongs_to :form_submission, Ceec.DataCollection.FormSubmission
    belongs_to :project, Ceec.Projects.Project
    belongs_to :beneficiary, Ceec.Projects.Beneficiary, on_replace: :nilify

    timestamps()
  end

  @doc false
  def changeset(attachment, attrs) do
    attachment
    |> cast(attrs, [
      :filename, :original_filename, :file_path, :file_size, :content_type,
      :file_type, :description, :uploaded_by, :uploaded_at, :image_width,
      :image_height, :gps_latitude, :gps_longitude, :form_submission_id,
      :project_id, :beneficiary_id
    ])
    |> validate_required([:filename, :original_filename, :file_path, :file_size, :content_type])
    |> validate_inclusion(:file_type, ["photo", "document", "audio", "video", "other"])
    |> validate_number(:file_size, greater_than: 0)
    |> validate_number(:image_width, greater_than: 0)
    |> validate_number(:image_height, greater_than: 0)
    |> validate_number(:gps_latitude, greater_than_or_equal_to: -90, less_than_or_equal_to: 90)
    |> validate_number(:gps_longitude, greater_than_or_equal_to: -180, less_than_or_equal_to: 180)
    |> foreign_key_constraint(:form_submission_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:beneficiary_id)
    |> set_uploaded_at()
    |> determine_file_type()
  end

  defp set_uploaded_at(changeset) do
    case get_field(changeset, :uploaded_at) do
      nil -> put_change(changeset, :uploaded_at, DateTime.utc_now())
      _ -> changeset
    end
  end

  defp determine_file_type(changeset) do
    case get_field(changeset, :file_type) do
      nil ->
        content_type = get_field(changeset, :content_type)
        file_type = infer_file_type(content_type)
        put_change(changeset, :file_type, file_type)
      _ -> changeset
    end
  end

  defp infer_file_type(content_type) when is_binary(content_type) do
    cond do
      String.starts_with?(content_type, "image/") -> "photo"
      String.starts_with?(content_type, "audio/") -> "audio"
      String.starts_with?(content_type, "video/") -> "video"
      content_type in ["application/pdf", "application/msword", 
                      "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                      "text/plain", "text/csv"] -> "document"
      true -> "other"
    end
  end
  defp infer_file_type(_), do: "other"

  @doc """
  Returns a human-readable file size.
  """
  def human_file_size(%__MODULE__{file_size: size}) when is_integer(size) do
    human_file_size(size)
  end
  def human_file_size(size) when is_integer(size) do
    cond do
      size < 1024 -> "#{size} B"
      size < 1024 * 1024 -> "#{Float.round(size / 1024, 1)} KB"
      size < 1024 * 1024 * 1024 -> "#{Float.round(size / (1024 * 1024), 1)} MB"
      true -> "#{Float.round(size / (1024 * 1024 * 1024), 1)} GB"
    end
  end
  def human_file_size(_), do: "Unknown"

  @doc """
  Checks if the attachment is an image.
  """
  def image?(%__MODULE__{file_type: "photo"}), do: true
  def image?(%__MODULE__{content_type: content_type}) when is_binary(content_type) do
    String.starts_with?(content_type, "image/")
  end
  def image?(_), do: false

  @doc """
  Gets the file extension from the original filename.
  """
  def file_extension(%__MODULE__{original_filename: filename}) when is_binary(filename) do
    case Path.extname(filename) do
      "" -> nil
      ext -> String.downcase(ext)
    end
  end
  def file_extension(_), do: nil
end