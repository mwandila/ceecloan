# Surveys LiveViews

Purpose:
- LiveViews for listing, showing, and editing surveys.

Suggested files:
- form_live.ex  (multi-step CEEC survey)
- list_live.ex  (optional index/list page)
- show_live.ex  (optional detail view)

Notes:
- Keep heavy domain logic in Ceec.Surveys.
- LiveView assigns drive state; components render UI.
