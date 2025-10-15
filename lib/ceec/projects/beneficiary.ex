defmodule Ceec.Projects.Beneficiary do
  use Ecto.Schema
  import Ecto.Changeset

  schema "beneficiaries" do
    field :first_name, :string
    field :last_name, :string
    field :identifier, :string  # Unique ID for the beneficiary
    field :phone_number, :string
    field :email, :string
    field :date_of_birth, :date
    field :gender, :string
    field :marital_status, :string
    
    # Location information
    field :address, :string
    field :village, :string
    field :district, :string
    field :region, :string
    field :gps_latitude, :decimal
    field :gps_longitude, :decimal
    
    # Socio-economic information
    field :education_level, :string
    field :occupation, :string
    field :household_size, :integer
    field :monthly_income, :decimal
    field :has_disability, :boolean, default: false
    field :disability_type, :string
    
    # Project-specific fields
    field :enrollment_date, :date
    field :status, :string, default: "active"  # active, inactive, graduated, dropped_out
    field :category, :string  # primary, secondary, indirect beneficiary
    
    # Additional metadata
    field :notes, :string
    field :profile_photo_url, :string
    
    # Relationships
    belongs_to :project, Ceec.Projects.Project
    has_many :form_submissions, Ceec.DataCollection.FormSubmission

    timestamps()
  end

  @doc false
  def changeset(beneficiary, attrs) do
    beneficiary
    |> cast(attrs, [
      :first_name, :last_name, :identifier, :phone_number, :email,
      :date_of_birth, :gender, :marital_status, :address, :village,
      :district, :region, :gps_latitude, :gps_longitude, :education_level,
      :occupation, :household_size, :monthly_income, :has_disability,
      :disability_type, :enrollment_date, :status, :category, :notes,
      :profile_photo_url, :project_id
    ])
    |> validate_required([
      :first_name, :last_name, :identifier, :gender, :enrollment_date,
      :status, :project_id
    ])
    |> validate_inclusion(:gender, ["male", "female", "other", "prefer_not_to_say"])
    |> validate_inclusion(:marital_status, [
      "single", "married", "divorced", "widowed", "separated"
    ])
    |> validate_inclusion(:education_level, [
      "none", "primary", "secondary", "tertiary", "vocational", "other"
    ])
    |> validate_inclusion(:status, [
      "active", "inactive", "graduated", "dropped_out", "transferred"
    ])
    |> validate_inclusion(:category, [
      "primary", "secondary", "indirect"
    ])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
    |> validate_format(:phone_number, ~r/^\+?[\d\s\-\(\)]+$/, 
      message: "must be a valid phone number")
    |> validate_number(:household_size, greater_than: 0)
    |> validate_number(:monthly_income, greater_than_or_equal_to: 0)
    |> validate_number(:gps_latitude, greater_than_or_equal_to: -90, less_than_or_equal_to: 90)
    |> validate_number(:gps_longitude, greater_than_or_equal_to: -180, less_than_or_equal_to: 180)
    |> unique_constraint(:identifier)
    |> foreign_key_constraint(:project_id)
  end

  def full_name(%__MODULE__{first_name: first, last_name: last}) do
    "#{first} #{last}"
  end

  def age(%__MODULE__{date_of_birth: nil}), do: nil
  def age(%__MODULE__{date_of_birth: dob}) do
    today = Date.utc_today()
    Date.diff(today, dob) |> div(365)
  end
end