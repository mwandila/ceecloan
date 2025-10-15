defmodule Ceec.CeecSurveysTest do
  use Ceec.DataCase, async: true

  alias Ceec.CeecSurveys
  alias Ceec.CeecSurveys.Survey

  @base_attrs %{
    first_name: "John",
    last_name: "Doe",
    phone_number: "+260912345678",
    province: "Lusaka",
    district: "Lusaka",
    education_level: "Diploma",
    employment_status: "Employed",
    funding_purpose: "Working capital",
    funding_amount_requested: "15000.00",
    funding_type_preferred: "Loan",
    has_bank_account: true,
    bank_name: "Zanaco",
    account_number: "123456789012",
    business_skills_rating: 3,
    requires_mentorship: false,
    has_disability: false
  }

  defp sample_attrs(overrides \\ %{}) do
    base =
      @base_attrs
      |> Map.put(
        :national_id,
        Integer.to_string(5_000_000_000 + System.unique_integer([:positive]))
      )

    Map.merge(base, overrides)
  end

  test "create_survey/1 accepts post-loan assessment fields" do
    attrs =
      sample_attrs(%{
        has_received_loan: true,
        loan_disbursement_date: ~D[2024-02-10],
        loan_amount_received: "12000.00",
        loan_usage_description: "Purchased equipment and stocked inventory",
        loan_usage_categories: ["Equipment Purchase", "Inventory & Stock"],
        loan_repayment_status: "On track",
        loan_satisfaction_rating: 4,
        loan_impact_on_livelihood: "Household income improved",
        monthly_revenue_change: "Increased slightly"
      })

    assert {:ok, %Survey{} = survey} = CeecSurveys.create_survey(attrs)
    assert survey.has_received_loan
    assert survey.loan_repayment_status == "On track"
    assert survey.loan_usage_categories == ["Equipment Purchase", "Inventory & Stock"]
  end

  test "changeset enforces loan follow-up requirements when loan is received" do
    attrs =
      sample_attrs(%{
        has_received_loan: true,
        loan_disbursement_date: nil,
        loan_amount_received: nil,
        loan_usage_description: "",
        loan_usage_categories: [],
        loan_repayment_status: nil,
        loan_satisfaction_rating: nil
      })

    changeset = Survey.changeset(%Survey{}, attrs)
    errors = errors_on(changeset)

    assert "can't be blank" in errors.loan_disbursement_date
    assert "can't be blank" in errors.loan_amount_received
    assert "can't be blank" in errors.loan_usage_description
    assert "must select at least one option" in errors.loan_usage_categories
    assert "can't be blank" in errors.loan_repayment_status
  end

  test "changeset requires support details when additional support flagged" do
    attrs =
      sample_attrs(%{
        requires_additional_support: true,
        additional_support_details: ""
      })

    errors = %Survey{} |> Survey.changeset(attrs) |> errors_on()
    assert "can't be blank" in errors.additional_support_details
  end
end
