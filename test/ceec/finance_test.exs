defmodule Ceec.FinanceTest do
  use Ceec.DataCase

  alias Ceec.Finance

  describe "loans" do
    alias Ceec.Finance.Loan

    import Ceec.FinanceFixtures

    @invalid_attrs %{amount: nil, created_by: nil, interest_rate: nil, loan_id: nil, maturity_date: nil, project_name: nil, status: nil}

    test "list_loans/0 returns all loans" do
      loan = loan_fixture()
      assert Finance.list_loans() == [loan]
    end

    test "get_loan!/1 returns the loan with given id" do
      loan = loan_fixture()
      assert Finance.get_loan!(loan.id) == loan
    end

    test "create_loan/1 with valid data creates a loan" do
      valid_attrs = %{amount: "120.5", created_by: "some created_by", interest_rate: "120.5", loan_id: "some loan_id", maturity_date: ~D[2025-10-13], project_name: "some project_name", status: "some status"}

      assert {:ok, %Loan{} = loan} = Finance.create_loan(valid_attrs)
      assert loan.amount == Decimal.new("120.5")
      assert loan.created_by == "some created_by"
      assert loan.interest_rate == Decimal.new("120.5")
      assert loan.loan_id == "some loan_id"
      assert loan.maturity_date == ~D[2025-10-13]
      assert loan.project_name == "some project_name"
      assert loan.status == "some status"
    end

    test "create_loan/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finance.create_loan(@invalid_attrs)
    end

    test "update_loan/2 with valid data updates the loan" do
      loan = loan_fixture()
      update_attrs = %{amount: "456.7", created_by: "some updated created_by", interest_rate: "456.7", loan_id: "some updated loan_id", maturity_date: ~D[2025-10-14], project_name: "some updated project_name", status: "some updated status"}

      assert {:ok, %Loan{} = loan} = Finance.update_loan(loan, update_attrs)
      assert loan.amount == Decimal.new("456.7")
      assert loan.created_by == "some updated created_by"
      assert loan.interest_rate == Decimal.new("456.7")
      assert loan.loan_id == "some updated loan_id"
      assert loan.maturity_date == ~D[2025-10-14]
      assert loan.project_name == "some updated project_name"
      assert loan.status == "some updated status"
    end

    test "update_loan/2 with invalid data returns error changeset" do
      loan = loan_fixture()
      assert {:error, %Ecto.Changeset{}} = Finance.update_loan(loan, @invalid_attrs)
      assert loan == Finance.get_loan!(loan.id)
    end

    test "delete_loan/1 deletes the loan" do
      loan = loan_fixture()
      assert {:ok, %Loan{}} = Finance.delete_loan(loan)
      assert_raise Ecto.NoResultsError, fn -> Finance.get_loan!(loan.id) end
    end

    test "change_loan/1 returns a loan changeset" do
      loan = loan_fixture()
      assert %Ecto.Changeset{} = Finance.change_loan(loan)
    end
  end
end
