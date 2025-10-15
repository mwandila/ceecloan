defmodule CeecWeb.CeecSurveySuccessLive do
  use CeecWeb, :live_view
  alias Ceec.CeecSurveys

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Survey Submitted Successfully")}
  end

  def handle_params(%{"reference" => reference}, _uri, socket) do
    case CeecSurveys.get_survey_by_reference(reference) do
      nil ->
        socket =
          socket
          |> put_flash(:error, "Survey not found")
          |> push_navigate(to: ~p"/")

        {:noreply, socket}

      survey ->
        socket =
          socket
          |> assign(:survey, survey)
          |> assign(:page_title, "Survey Submitted - #{reference}")

        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 py-12">
      <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- Success Message -->
        <div class="bg-white shadow-lg rounded-lg overflow-hidden">
          <div class="px-6 py-8 sm:p-10 sm:pb-6 text-center">
            <!-- Success Icon -->
            <div class="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6">
              <.icon name="hero-check-circle" class="w-12 h-12 text-green-600" />
            </div>
            <!-- Success Title -->
            <h1 class="text-3xl font-bold text-gray-900 mb-4">Survey Successfully Submitted!</h1>
            <!-- Reference Number -->
            <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
              <p class="text-sm text-blue-600 font-medium">Your Reference Number</p>

              <p class="text-2xl font-bold text-blue-900">{@survey.reference_number}</p>

              <p class="text-xs text-blue-500 mt-1">Keep this number for your records</p>
            </div>
            <!-- Success Message -->
            <p class="text-lg text-gray-600 mb-8 max-w-2xl mx-auto">
              Thank you for completing the CEEC funding survey. Your application has been received and will be reviewed by our team.
              You will be contacted via phone or email regarding the next steps.
            </p>
          </div>
          <!-- Survey Details -->
          <div class="border-t border-gray-200 px-6 py-6 sm:px-10">
            <h2 class="text-lg font-semibold text-gray-900 mb-4">Application Summary</h2>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 text-sm">
              <div>
                <h3 class="font-medium text-gray-900 mb-2">Personal Information</h3>

                <p><strong>Name:</strong> {@survey.first_name} {@survey.last_name}</p>

                <p><strong>National ID:</strong> {@survey.national_id}</p>

                <p><strong>Phone:</strong> {@survey.phone_number}</p>

                <%= if @survey.province do %>
                  <p><strong>Province:</strong> {@survey.province}</p>
                <% end %>
              </div>

              <div>
                <h3 class="font-medium text-gray-900 mb-2">Funding Request</h3>

                <p><strong>Amount:</strong> ZMW {@survey.funding_amount_requested}</p>

                <p><strong>Type:</strong> {@survey.funding_type_preferred}</p>

                <%= if @survey.business_sector do %>
                  <p><strong>Business Sector:</strong> {@survey.business_sector}</p>
                <% end %>

                <p>
                  <strong>Submitted:</strong> {Calendar.strftime(
                    @survey.submitted_at || @survey.updated_at,
                    "%B %d, %Y at %I:%M %p"
                  )}
                </p>
              </div>
            </div>
          </div>
          <!-- Next Steps -->
          <div class="border-t border-gray-200 bg-gray-50 px-6 py-6 sm:px-10">
            <h2 class="text-lg font-semibold text-gray-900 mb-4">What Happens Next?</h2>

            <div class="space-y-4">
              <div class="flex items-start">
                <div class="flex-shrink-0">
                  <div class="w-8 h-8 bg-blue-600 text-white rounded-full flex items-center justify-center text-sm font-medium">
                    1
                  </div>
                </div>

                <div class="ml-4">
                  <h3 class="font-medium text-gray-900">Application Review</h3>

                  <p class="text-gray-600 text-sm">
                    Our team will review your application within 5-10 business days.
                  </p>
                </div>
              </div>

              <div class="flex items-start">
                <div class="flex-shrink-0">
                  <div class="w-8 h-8 bg-blue-600 text-white rounded-full flex items-center justify-center text-sm font-medium">
                    2
                  </div>
                </div>

                <div class="ml-4">
                  <h3 class="font-medium text-gray-900">Contact & Interview</h3>

                  <p class="text-gray-600 text-sm">
                    If your application meets our criteria, we'll contact you for an interview.
                  </p>
                </div>
              </div>

              <div class="flex items-start">
                <div class="flex-shrink-0">
                  <div class="w-8 h-8 bg-blue-600 text-white rounded-full flex items-center justify-center text-sm font-medium">
                    3
                  </div>
                </div>

                <div class="ml-4">
                  <h3 class="font-medium text-gray-900">Final Decision</h3>

                  <p class="text-gray-600 text-sm">
                    You'll receive notification about the funding decision within 30 days.
                  </p>
                </div>
              </div>
            </div>
          </div>
          <!-- Action Buttons -->
          <div class="border-t border-gray-200 px-6 py-6 sm:px-10">
            <div class="flex flex-col sm:flex-row gap-4 justify-center">
              <a
                href={~p"/"}
                class="inline-flex items-center justify-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 transition-colors"
              >
                <.icon name="hero-home" class="w-5 h-5 mr-2" /> Back to Home
              </a>
              <button
                phx-click={JS.dispatch("window:print")}
                class="inline-flex items-center justify-center px-6 py-3 border border-gray-300 text-base font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 transition-colors"
              >
                <.icon name="hero-printer" class="w-5 h-5 mr-2" /> Print Confirmation
              </button>
              <a
                href="/ceec-survey"
                class="inline-flex items-center justify-center px-6 py-3 border border-gray-300 text-base font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 transition-colors"
              >
                <.icon name="hero-plus" class="w-5 h-5 mr-2" /> New Application
              </a>
            </div>
          </div>
        </div>
        <!-- Important Notice -->
        <div class="mt-8 bg-yellow-50 border border-yellow-200 rounded-lg p-6">
          <div class="flex">
            <div class="flex-shrink-0">
              <.icon name="hero-exclamation-triangle" class="w-6 h-6 text-yellow-400" />
            </div>

            <div class="ml-3">
              <h3 class="text-sm font-medium text-yellow-800">Important Notice</h3>

              <div class="mt-2 text-sm text-yellow-700">
                <ul class="list-disc pl-5 space-y-1">
                  <li>Keep your reference number safe for future correspondence.</li>

                  <li>Ensure your phone number and email are active for communication.</li>

                  <li>Have your supporting documents ready when contacted.</li>

                  <li>
                    False information may result in disqualification from funding opportunities.
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
