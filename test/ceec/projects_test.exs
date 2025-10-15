defmodule Ceec.ProjectsTest do
  use Ceec.DataCase

  alias Ceec.Projects

  describe "projects" do
    alias Ceec.Projects.Project

    import Ceec.ProjectsFixtures

    @invalid_attrs %{budget: nil, description: nil, end_date: nil, name: nil, progress: nil, project_id: nil, start_date: nil, status: nil}

    test "list_projects/0 returns all projects" do
      project = project_fixture()
      assert Projects.list_projects() == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = project_fixture()
      assert Projects.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      valid_attrs = %{budget: "120.5", description: "some description", end_date: ~D[2025-10-13], name: "some name", progress: 42, project_id: "some project_id", start_date: ~D[2025-10-13], status: "some status"}

      assert {:ok, %Project{} = project} = Projects.create_project(valid_attrs)
      assert project.budget == Decimal.new("120.5")
      assert project.description == "some description"
      assert project.end_date == ~D[2025-10-13]
      assert project.name == "some name"
      assert project.progress == 42
      assert project.project_id == "some project_id"
      assert project.start_date == ~D[2025-10-13]
      assert project.status == "some status"
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture()
      update_attrs = %{budget: "456.7", description: "some updated description", end_date: ~D[2025-10-14], name: "some updated name", progress: 43, project_id: "some updated project_id", start_date: ~D[2025-10-14], status: "some updated status"}

      assert {:ok, %Project{} = project} = Projects.update_project(project, update_attrs)
      assert project.budget == Decimal.new("456.7")
      assert project.description == "some updated description"
      assert project.end_date == ~D[2025-10-14]
      assert project.name == "some updated name"
      assert project.progress == 43
      assert project.project_id == "some updated project_id"
      assert project.start_date == ~D[2025-10-14]
      assert project.status == "some updated status"
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = project_fixture()
      assert {:error, %Ecto.Changeset{}} = Projects.update_project(project, @invalid_attrs)
      assert project == Projects.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = Projects.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = project_fixture()
      assert %Ecto.Changeset{} = Projects.change_project(project)
    end
  end
end
