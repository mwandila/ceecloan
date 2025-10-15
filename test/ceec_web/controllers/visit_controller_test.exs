defmodule CeecWeb.VisitControllerTest do
  use CeecWeb.ConnCase

  import Ceec.MeDataFixtures

  @create_attrs %{findings: "some findings", gps_latitude: 120.5, gps_longitude: 120.5, notes: "some notes", purpose: "some purpose", recommendations: "some recommendations", status: "some status", visit_date: ~D[2025-10-12], visit_type: "some visit_type", visited_by: "some visited_by"}
  @update_attrs %{findings: "some updated findings", gps_latitude: 456.7, gps_longitude: 456.7, notes: "some updated notes", purpose: "some updated purpose", recommendations: "some updated recommendations", status: "some updated status", visit_date: ~D[2025-10-13], visit_type: "some updated visit_type", visited_by: "some updated visited_by"}
  @invalid_attrs %{findings: nil, gps_latitude: nil, gps_longitude: nil, notes: nil, purpose: nil, recommendations: nil, status: nil, visit_date: nil, visit_type: nil, visited_by: nil}

  describe "index" do
    test "lists all visits", %{conn: conn} do
      conn = get(conn, ~p"/visits")
      assert html_response(conn, 200) =~ "Listing Visits"
    end
  end

  describe "new visit" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/visits/new")
      assert html_response(conn, 200) =~ "New Visit"
    end
  end

  describe "create visit" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/visits", visit: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/visits/#{id}"

      conn = get(conn, ~p"/visits/#{id}")
      assert html_response(conn, 200) =~ "Visit #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/visits", visit: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Visit"
    end
  end

  describe "edit visit" do
    setup [:create_visit]

    test "renders form for editing chosen visit", %{conn: conn, visit: visit} do
      conn = get(conn, ~p"/visits/#{visit}/edit")
      assert html_response(conn, 200) =~ "Edit Visit"
    end
  end

  describe "update visit" do
    setup [:create_visit]

    test "redirects when data is valid", %{conn: conn, visit: visit} do
      conn = put(conn, ~p"/visits/#{visit}", visit: @update_attrs)
      assert redirected_to(conn) == ~p"/visits/#{visit}"

      conn = get(conn, ~p"/visits/#{visit}")
      assert html_response(conn, 200) =~ "some updated findings"
    end

    test "renders errors when data is invalid", %{conn: conn, visit: visit} do
      conn = put(conn, ~p"/visits/#{visit}", visit: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Visit"
    end
  end

  describe "delete visit" do
    setup [:create_visit]

    test "deletes chosen visit", %{conn: conn, visit: visit} do
      conn = delete(conn, ~p"/visits/#{visit}")
      assert redirected_to(conn) == ~p"/visits"

      assert_error_sent 404, fn ->
        get(conn, ~p"/visits/#{visit}")
      end
    end
  end

  defp create_visit(_) do
    visit = visit_fixture()
    %{visit: visit}
  end
end
