# Survey components (LiveComponents)

Purpose:
- Split the survey UI into small, focused components, each responsible for a single step or section.
- Keep minimal logic in components; business rules come from Ceec.Surveys context.

Suggested files (to be created in the refactor step):
- personal_info_component.ex
- address_component.ex
- business_component.ex
- funding_component.ex
- loan_followup_component.ex

Coding guidelines:
- Module namespace: CeecWeb.SurveyComponents.*
- Props (attrs): expect a Phoenix.HTML.Form as :form, keep attrs explicit.
- Keep functions stateless; prefer deriving options from context (Ceec.Surveys).
