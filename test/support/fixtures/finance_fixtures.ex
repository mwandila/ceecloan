defmodule Ceec.FinanceFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ceec.Finance` context.
  """

  @doc """
  Generate a unique loan loan_id.
  """
  def unique_loan_loan_id, do: "some loan_id#{System.unique_integer([:positive])}"

  @doc """
  Generate a loan.
  """
  def loan_fixture(attrs \\ %{}) do
    {:ok, loan} =
      attrs
      |> Enum.into(%{
        amount: "120.5",
        created_by: "some created_by",
        interest_rate: "120.5",
        loan_id: unique_loan_loan_id(),
        maturity_date: ~D[2025-10-13],
        project_name: "some project_name",
        status: "some status"
      })
      |> Ceec.Finance.create_loan()

    loan
  end
end
