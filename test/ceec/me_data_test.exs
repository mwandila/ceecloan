defmodule Ceec.MeDataTest do
  use Ceec.DataCase

  alias Ceec.MeData

  describe "visits" do
    alias Ceec.MeData.Visit

    import Ceec.MeDataFixtures

    @invalid_attrs %{findings: nil, gps_latitude: nil, gps_longitude: nil, notes: nil, purpose: nil, recommendations: nil, status: nil, visit_date: nil, visit_type: nil, visited_by: nil}

    test "list_visits/0 returns all visits" do
      visit = visit_fixture()
      assert MeData.list_visits() == [visit]
    end

    test "get_visit!/1 returns the visit with given id" do
      visit = visit_fixture()
      assert MeData.get_visit!(visit.id) == visit
    end

    test "create_visit/1 with valid data creates a visit" do
      valid_attrs = %{findings: "some findings", gps_latitude: 120.5, gps_longitude: 120.5, notes: "some notes", purpose: "some purpose", recommendations: "some recommendations", status: "some status", visit_date: ~D[2025-10-12], visit_type: "some visit_type", visited_by: "some visited_by"}

      assert {:ok, %Visit{} = visit} = MeData.create_visit(valid_attrs)
      assert visit.findings == "some findings"
      assert visit.gps_latitude == 120.5
      assert visit.gps_longitude == 120.5
      assert visit.notes == "some notes"
      assert visit.purpose == "some purpose"
      assert visit.recommendations == "some recommendations"
      assert visit.status == "some status"
      assert visit.visit_date == ~D[2025-10-12]
      assert visit.visit_type == "some visit_type"
      assert visit.visited_by == "some visited_by"
    end

    test "create_visit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = MeData.create_visit(@invalid_attrs)
    end

    test "update_visit/2 with valid data updates the visit" do
      visit = visit_fixture()
      update_attrs = %{findings: "some updated findings", gps_latitude: 456.7, gps_longitude: 456.7, notes: "some updated notes", purpose: "some updated purpose", recommendations: "some updated recommendations", status: "some updated status", visit_date: ~D[2025-10-13], visit_type: "some updated visit_type", visited_by: "some updated visited_by"}

      assert {:ok, %Visit{} = visit} = MeData.update_visit(visit, update_attrs)
      assert visit.findings == "some updated findings"
      assert visit.gps_latitude == 456.7
      assert visit.gps_longitude == 456.7
      assert visit.notes == "some updated notes"
      assert visit.purpose == "some updated purpose"
      assert visit.recommendations == "some updated recommendations"
      assert visit.status == "some updated status"
      assert visit.visit_date == ~D[2025-10-13]
      assert visit.visit_type == "some updated visit_type"
      assert visit.visited_by == "some updated visited_by"
    end

    test "update_visit/2 with invalid data returns error changeset" do
      visit = visit_fixture()
      assert {:error, %Ecto.Changeset{}} = MeData.update_visit(visit, @invalid_attrs)
      assert visit == MeData.get_visit!(visit.id)
    end

    test "delete_visit/1 deletes the visit" do
      visit = visit_fixture()
      assert {:ok, %Visit{}} = MeData.delete_visit(visit)
      assert_raise Ecto.NoResultsError, fn -> MeData.get_visit!(visit.id) end
    end

    test "change_visit/1 returns a visit changeset" do
      visit = visit_fixture()
      assert %Ecto.Changeset{} = MeData.change_visit(visit)
    end
  end
end
