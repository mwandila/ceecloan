defmodule CeecWeb.CeecSurveyDashboardLive do
  use CeecWeb, :live_view
  alias Ceec.CeecSurveys

  def mount(_params, _session, socket) do
    stats = CeecSurveys.get_survey_stats()
    completion_analytics = CeecSurveys.get_completion_analytics()
    recent_surveys = CeecSurveys.get_recent_completed_surveys(5)

    socket =
      socket
      |> assign(:page_title, "CEEC Survey Dashboard")
      |> assign(:stats, stats)
      |> assign(:completion_analytics, completion_analytics)
      |> assign(:recent_surveys, recent_surveys)
      |> assign(:search_term, "")
      |> assign(:search_results, [])

    {:ok, socket}
  end

  def handle_event("search", %{"search_term" => term}, socket) when term != "" do
    results = CeecSurveys.search_surveys(term)

    socket =
      socket
      |> assign(:search_term, term)
      |> assign(:search_results, results)

    {:noreply, socket}
  end

  def handle_event("search", %{"search_term" => ""}, socket) do
    socket =
      socket
      |> assign(:search_term, "")
      |> assign(:search_results, [])

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
      <!-- Header -->
      <div class="bg-white shadow">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="py-6">
            <div class="flex items-center justify-between">
              <div>
                <h1 class="text-3xl font-bold text-gray-900">CEEC Survey Dashboard</h1>

                <p class="mt-1 text-sm text-gray-500">Citizens Economic Empowerment Commission</p>
              </div>

              <div class="flex space-x-3">
                <a
                  href="/ceec-survey"
                  class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
                >
                  <.icon name="hero-plus" class="w-4 h-4 mr-2" /> New Survey
                </a>
                <a
                  href="/"
                  class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
                >
                  <.icon name="hero-home" class="w-4 h-4 mr-2" /> Home
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Stats Cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <.icon name="hero-clipboard-document-list" class="w-8 h-8 text-blue-600" />
                </div>

                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Total Surveys</dt>

                    <dd class="text-3xl font-bold text-gray-900">{@stats.total_surveys}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <.icon name="hero-document-text" class="w-8 h-8 text-yellow-600" />
                </div>

                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Draft Surveys</dt>

                    <dd class="text-3xl font-bold text-gray-900">{@stats.draft_count}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <.icon name="hero-paper-airplane" class="w-8 h-8 text-green-600" />
                </div>

                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Submitted</dt>

                    <dd class="text-3xl font-bold text-gray-900">{@stats.submitted_count}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <.icon name="hero-check-circle" class="w-8 h-8 text-purple-600" />
                </div>

                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Reviewed</dt>

                    <dd class="text-3xl font-bold text-gray-900">{@stats.reviewed_count}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
          <!-- Top Provinces -->
          <div class="bg-white shadow rounded-lg">
            <div class="px-6 py-5 border-b border-gray-200">
              <h3 class="text-lg font-medium text-gray-900">Top Provinces</h3>

              <p class="mt-1 text-sm text-gray-500">Survey submissions by province</p>
            </div>

            <div class="px-6 py-4">
              <%= if Enum.any?(@stats.top_provinces) do %>
                <div class="space-y-3">
                  <%= for {province, count} <- @stats.top_provinces do %>
                    <div class="flex items-center justify-between">
                      <span class="text-sm font-medium text-gray-900">{province}</span>
                      <span class="text-sm text-gray-500">{count} surveys</span>
                    </div>
                  <% end %>
                </div>
              <% else %>
                <p class="text-gray-500 text-sm">No data available</p>
              <% end %>
            </div>
          </div>
          <!-- Funding Types -->
          <div class="bg-white shadow rounded-lg">
            <div class="px-6 py-5 border-b border-gray-200">
              <h3 class="text-lg font-medium text-gray-900">Funding Types</h3>

              <p class="mt-1 text-sm text-gray-500">Distribution by preferred funding type</p>
            </div>

            <div class="px-6 py-4">
              <%= if map_size(@stats.funding_type_distribution) > 0 do %>
                <div class="space-y-3">
                  <%= for {type, count} <- @stats.funding_type_distribution do %>
                    <div class="flex items-center justify-between">
                      <span class="text-sm font-medium text-gray-900">{type}</span>
                      <span class="text-sm text-gray-500">{count} requests</span>
                    </div>
                  <% end %>
                </div>
              <% else %>
                <p class="text-gray-500 text-sm">No data available</p>
              <% end %>
            </div>
          </div>
        </div>
        <!-- Search Section -->
        <div class="bg-white shadow rounded-lg mb-8">
          <div class="px-6 py-5 border-b border-gray-200">
            <h3 class="text-lg font-medium text-gray-900">Search Surveys</h3>

            <p class="mt-1 text-sm text-gray-500">
              Search by name, national ID, reference number, or business name
            </p>
          </div>

          <div class="px-6 py-4">
            <form phx-change="search" phx-submit="search">
              <div class="max-w-md">
                <input
                  type="text"
                  name="search_term"
                  value={@search_term}
                  placeholder="Enter search term..."
                  class="block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                />
              </div>
            </form>

            <%= if Enum.any?(@search_results) do %>
              <div class="mt-4">
                <h4 class="text-sm font-medium text-gray-900 mb-3">
                  Search Results ({length(@search_results)})
                </h4>

                <div class="space-y-3">
                  <%= for survey <- @search_results do %>
                    <div class="border border-gray-200 rounded-lg p-4">
                      <div class="flex items-center justify-between">
                        <div>
                          <h5 class="font-medium text-gray-900">
                            {survey.first_name} {survey.last_name}
                          </h5>

                          <p class="text-sm text-gray-600">ID: {survey.national_id} |
                            Ref: {survey.reference_number} |
                            Status: <span class="capitalize">{survey.survey_status}</span></p>

                          <%= if survey.business_name do %>
                            <p class="text-sm text-gray-500">Business: {survey.business_name}</p>
                          <% end %>
                        </div>

                        <div class="text-right text-sm text-gray-500">
                          <%= if survey.funding_amount_requested do %>
                            <p>ZMW {survey.funding_amount_requested}</p>
                          <% end %>

                          <p>{Calendar.strftime(survey.inserted_at, "%b %d, %Y")}</p>
                        </div>
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>
            <% end %>

            <%= if @search_term != "" and Enum.empty?(@search_results) do %>
              <div class="mt-4 text-center py-4">
                <.icon name="hero-magnifying-glass" class="w-12 h-12 text-gray-400 mx-auto mb-2" />
                <p class="text-gray-500">No surveys found matching "{@search_term}"</p>
              </div>
            <% end %>
          </div>
        </div>
        <!-- Recent Surveys -->
        <div class="bg-white shadow rounded-lg">
          <div class="px-6 py-5 border-b border-gray-200">
            <h3 class="text-lg font-medium text-gray-900">Recent Completed Surveys</h3>

            <p class="mt-1 text-sm text-gray-500">Latest submitted applications</p>
          </div>

          <div class="px-6 py-4">
            <%= if Enum.any?(@recent_surveys) do %>
              <div class="space-y-4">
                <%= for survey <- @recent_surveys do %>
                  <div class="border-b border-gray-200 pb-4 last:border-b-0 last:pb-0">
                    <div class="flex items-center justify-between">
                      <div class="flex-1">
                        <h4 class="font-medium text-gray-900">
                          {survey.first_name} {survey.last_name}
                        </h4>

                        <div class="mt-1 text-sm text-gray-600">
                          <span>Ref: {survey.reference_number}</span> <span class="mx-2">•</span>
                          <span>{survey.province || "Not specified"}</span>
                          <span class="mx-2">•</span>
                          <span>{survey.funding_type_preferred || "Not specified"}</span>
                        </div>

                        <%= if survey.funding_amount_requested do %>
                          <p class="text-sm font-medium text-green-600 mt-1">
                            Funding Request: ZMW {survey.funding_amount_requested}
                          </p>
                        <% end %>
                      </div>

                      <div class="text-right text-sm text-gray-500">
                        <div class={[
                          "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium mb-1",
                          case survey.survey_status do
                            "draft" -> "bg-yellow-100 text-yellow-800"
                            "submitted" -> "bg-blue-100 text-blue-800"
                            "reviewed" -> "bg-green-100 text-green-800"
                            _ -> "bg-gray-100 text-gray-800"
                          end
                        ]}>
                          {String.capitalize(survey.survey_status)}
                        </div>

                        <p>{Calendar.strftime(survey.updated_at, "%b %d, %Y")}</p>
                      </div>
                    </div>
                  </div>
                <% end %>
              </div>
            <% else %>
              <div class="text-center py-8">
                <.icon
                  name="hero-clipboard-document-list"
                  class="w-12 h-12 text-gray-400 mx-auto mb-4"
                />
                <p class="text-gray-500">No completed surveys yet</p>

                <a
                  href="/ceec-survey"
                  class="mt-2 inline-flex items-center text-sm text-blue-600 hover:text-blue-500"
                >
                  Create the first survey <.icon name="hero-arrow-right" class="w-4 h-4 ml-1" />
                </a>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
