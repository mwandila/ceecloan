defmodule Ceec.Finance.Loan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "loans" do
    field :amount, :decimal
    field :created_by, :string
    field :interest_rate, :decimal
    field :loan_id, :string
    field :maturity_date, :date
    field :project_name, :string
    field :status, :string
    field :loan_type, :string
    
    # Public loan application fields
    field :applicant_name, :string
    field :first_name, :string
    field :last_name, :string
    field :business_name, :string
    field :phone, :string
    field :email, :string
    field :nrc, :string
    field :business_type, :string
    field :years_in_business, :integer
    field :purpose, :string
    field :province, :string
    field :district, :string
    field :constituency, :string
    field :rejection_reason, :string
    field :disbursed_at, :utc_datetime
    
    belongs_to :project, Ceec.Projects.Project
    belongs_to :borrower, Ceec.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(loan, attrs) do
    loan
    |> cast(attrs, [
      # Administrative fields
      :loan_id, :project_name, :amount, :interest_rate, :maturity_date, :status, :created_by, :loan_type, :project_id, :borrower_id,
      # Public application fields  
      :applicant_name, :first_name, :last_name, :business_name, :phone, :email, :nrc, :business_type, :years_in_business, :purpose, :province, :district, :constituency, :rejection_reason, :disbursed_at
    ])
    |> validate_required_for_type(attrs)
    |> validate_inclusion(:loan_type, ["Microfinance", "SME Loan", "Agricultural", "Housing", "Education", "Health", "Infrastructure", "Energy"])
    |> unique_constraint(:loan_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:borrower_id)
  end
  
  # Different validation requirements based on loan source
  defp validate_required_for_type(changeset, attrs) do
    cond do
      # Public loan application (has first_name or business_name)
      Map.has_key?(attrs, "first_name") || Map.has_key?(attrs, "business_name") ||
      Map.has_key?(attrs, :first_name) || Map.has_key?(attrs, :business_name) ->
        changeset
        |> validate_required([:amount, :loan_type, :first_name, :last_name, :business_name])
        |> put_change(:status, "pending")
        |> put_applicant_name()
        
      # Administrative loan (has created_by)
      true ->
        validate_required(changeset, [:loan_id, :amount, :interest_rate, :maturity_date, :status, :created_by, :loan_type])
    end
  end
  
  # Helper to set applicant_name from first_name + last_name
  defp put_applicant_name(changeset) do
    first_name = get_field(changeset, :first_name)
    last_name = get_field(changeset, :last_name)
    
    if first_name && last_name do
      put_change(changeset, :applicant_name, "#{first_name} #{last_name}")
    else
      changeset
    end
  end
end
