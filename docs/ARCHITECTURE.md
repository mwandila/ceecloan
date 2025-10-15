# CEEC Phoenix App Architecture (LiveView-first)

Goal: Keep a clear separation between backend domain logic and the LiveView-based frontend, without introducing external SPA frameworks.

High-level layers:
- Domain (lib/ceec): Ecto schemas, contexts, business rules, services. No Phoenix HTML here.
- Web (lib/ceec_web): LiveViews, LiveComponents, Controllers, Views/Templates, and Web-specific helpers. Pure presentation + minimal orchestration.
- Assets (assets): Static assets, LiveView hooks, small JS helpers.
- Data (priv/repo): Migrations, seeds.
- Tests (test): Mirrors lib layout (domain vs web).

Proposed structure (key parts):

lib/
  ceec/
    surveys/               # domain for surveys/questionnaires
      survey.ex            # schema(s)
      surveys.ex           # context API (CRUD + domain logic)
      services/            # optional, domain services (e.g., calculators)
    projects/
      project.ex
      beneficiary.ex
      projects.ex
  ceec_web/
    components/
      layout/              # shell pieces (header/nav/footer)
      form/                # shared inputs, validation helpers
      survey/              # split monolithic survey_components.ex
        personal_info_component.ex
        address_component.ex
        business_component.ex
        funding_component.ex
        loan_followup_component.ex
    live/
      surveys/
        form_live.ex       # formerly CeecSurveyLive
        list_live.ex       # (optional) index/list page
        show_live.ex       # (optional) details page
      projects/
        ...
    controllers/
      page_controller.ex
      survey_controller.ex (if any non-Live pages)
    router.ex
    endpoint.ex

assets/
  js/
    hooks/
    components/
    pages/

Key conventions:
- Context-first: Options like loan_usage_options, monthly_revenue_changes belong in Ceec.Surveys (context) and are consumed by web layer. Avoid placing business rules in ceec_web.
- LiveComponent sizing: Keep each component under ~200-250 LOC; prefer smaller focused components composed in LiveViews.
- Module names: CeecWeb.SurveyComponents.* for component modules; CeecWeb.Surveys.* for LiveViews.
- Files follow module names: ceec_web/components/survey/loan_followup_component.ex defines CeecWeb.SurveyComponents.LoanFollowupComponent.
- Routing: No change needed when only moving files; only adjust module names if we rename LiveViews.

Refactor plan (phased, safe):
1) Scaffold folders (done here). No behavior change.
2) Split lib/ceec_web/components/survey_components.ex into 5 components under components/survey/.
3) Move CeecSurveyLive to lib/ceec_web/live/surveys/form_live.ex and rename to CeecWeb.Surveys.FormLive. Update router if it references the old module.
4) Compile and fix warnings. Add basic tests for components.

Testing notes:
- Add LiveView tests under test/ceec_web/live/surveys/*. ExUnit + Phoenix.LiveViewTest.
- Component unit tests under test/ceec_web/components/survey/*.

Deployment notes:
- No operational change; all refactors should be internal to the code structure.
