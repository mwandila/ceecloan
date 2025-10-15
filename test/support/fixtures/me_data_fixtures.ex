defmodule Ceec.MeDataFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ceec.MeData` context.
  """

  @doc """
  Generate a visit.
  """
  def visit_fixture(attrs \\ %{}) do
    {:ok, visit} =
      attrs
      |> Enum.into(%{
        findings: "some findings",
        gps_latitude: 120.5,
        gps_longitude: 120.5,
        notes: "some notes",
        purpose: "some purpose",
        recommendations: "some recommendations",
        status: "some status",
        visit_date: ~D[2025-10-12],
        visit_type: "some visit_type",
        visited_by: "some visited_by"
      })
      |> Ceec.MeData.create_visit()

    visit
  end
end
