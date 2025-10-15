defmodule Ceec.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ceec.Projects` context.
  """

  @doc """
  Generate a unique project project_id.
  """
  def unique_project_project_id, do: "some project_id#{System.unique_integer([:positive])}"

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        budget: "120.5",
        description: "some description",
        end_date: ~D[2025-10-13],
        name: "some name",
        progress: 42,
        project_id: unique_project_project_id(),
        start_date: ~D[2025-10-13],
        status: "some status"
      })
      |> Ceec.Projects.create_project()

    project
  end
end
