defmodule CeecWeb.ProjectLive.Index do
  use CeecWeb, :live_view

  alias Ceec.Projects
  alias Ceec.Projects.Project

  @impl true
  def mount(_params, _session, socket) do
    socket = 
      socket
      |> assign(:search, "")
      |> assign(:status_filter, "All")
      |> assign(:sort_by, "Name")
      |> assign(:per_page, 5)
      |> load_projects(1)
    
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    socket = load_projects(socket, page)
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Project")
    |> assign(:project, Projects.get_project!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, %Project{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Projects")
    |> assign(:project, nil)
  end

  @impl true
  def handle_info({CeecWeb.ProjectLive.FormComponent, {:saved, project}}, socket) do
    {:noreply, stream_insert(socket, :projects, project)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = Projects.get_project!(id)
    {:ok, _} = Projects.delete_project(project)

    # Reload current page
    socket = load_projects(socket, socket.assigns.pagination.page)
    {:noreply, socket}
  end
  
  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    socket = 
      socket
      |> assign(:search, search)
      |> load_projects(1) # Reset to first page on search
    {:noreply, socket}
  end
  
  @impl true
  def handle_event("filter_status", %{"status" => status}, socket) do
    socket = 
      socket
      |> assign(:status_filter, status)
      |> load_projects(1) # Reset to first page on filter
    {:noreply, socket}
  end
  
  @impl true
  def handle_event("sort_by", %{"sort" => sort_by}, socket) do
    socket = 
      socket
      |> assign(:sort_by, sort_by)
      |> load_projects(socket.assigns.pagination.page) # Keep current page
    {:noreply, socket}
  end
  
  @impl true
  def handle_event("goto_page", %{"page" => page}, socket) do
    page = String.to_integer(page)
    socket = load_projects(socket, page)
    {:noreply, socket}
  end
  
  defp load_projects(socket, page) do
    filters = %{
      search: socket.assigns.search,
      status: socket.assigns.status_filter,
      sort_by: socket.assigns.sort_by
    }
    
    pagination_data = Projects.list_projects_paginated(page, socket.assigns.per_page, filters)
    
    socket
    |> assign(:pagination, pagination_data)
    |> stream(:projects, pagination_data.projects, reset: true)
  end
end
