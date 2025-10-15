defmodule CeecWeb.Router do
  use CeecWeb, :router

  import CeecWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CeecWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CeecWeb do
    pipe_through :browser

    # Root page - redirect based on authentication
    get "/", PageController, :home
    
    # Public loan application routes (no authentication required)
    get "/loans/apply", LoanApplicationController, :new
    post "/loans/apply", LoanApplicationController, :create
    get "/loans/status", LoanApplicationController, :status
    post "/loans/status", LoanApplicationController, :check_status

    # M&E Data Collection Routes
    resources "/visits", VisitController
    
    # Legacy Survey Management (redirects to builder)
    get "/surveys/new", SurveyController, :redirect_to_builder
    resources "/surveys", SurveyController, except: [:new] do
      resources "/responses", SurveyResponseController, except: [:index]
    end

    # Survey responses management
    get "/responses", SurveyResponseController, :index
    get "/responses/:id", SurveyResponseController, :show
    get "/responses/:id/edit", SurveyResponseController, :edit
    put "/responses/:id", SurveyResponseController, :update
    delete "/responses/:id", SurveyResponseController, :delete
    
    
    # Form Builder routes
    resources "/form-builder", FormBuilderController, param: "id" do
      get "/builder", FormBuilderController, :builder
      post "/update-schema", FormBuilderController, :update_schema
      get "/preview", FormBuilderController, :preview
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", CeecWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ceec, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CeecWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", CeecWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{CeecWeb.UserAuth, :redirect_if_user_is_authenticated}],
      layout: {CeecWeb.Layouts, :auth} do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", CeecWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{CeecWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      
      # User management routes (admin functionality)
      live "/admin/users", UserLive.Index, :index
      live "/admin/users/new", UserLive.Index, :new
      live "/admin/users/:id/edit", UserLive.Index, :edit
      live "/admin/users/:id", UserLive.Show, :show
      live "/admin/users/:id/show/edit", UserLive.Show, :edit
      
      # Project management routes
      live "/projects", ProjectLive.Index, :index
      live "/projects/new", ProjectLive.Index, :new
      live "/projects/:id/edit", ProjectLive.Index, :edit
      live "/projects/:id", ProjectLive.Show, :show
      live "/projects/:id/show/edit", ProjectLive.Show, :edit
      
      # Loan management routes (existing)
      live "/loans", LoanLive.Index, :index
      live "/loans/new", LoanLive.Index, :new
      live "/loans/:id/edit", LoanLive.Index, :edit
      live "/loans/:id", LoanLive.Show, :show
      live "/loans/:id/show/edit", LoanLive.Show, :edit
      
      # Admin Loan Application Review and Approval routes (new)
      get "/admin/loan-applications", AdminLoanController, :index
      get "/admin/loan-applications/:id", AdminLoanController, :show
      post "/admin/loan-applications/:id/approve", AdminLoanController, :approve
      post "/admin/loan-applications/:id/reject", AdminLoanController, :reject
      post "/admin/loan-applications/:id/disburse", AdminLoanController, :disburse
      get "/admin/loan-applications/:id/edit", AdminLoanController, :edit
      put "/admin/loan-applications/:id", AdminLoanController, :update
      
      # Loan-Project Mapping Management
      live "/admin/mappings", MappingLive.Index, :index
      
      # System settings (superadmin only)
      live "/admin/settings", AdminLive.Settings, :index
      
      # Dashboard route (authenticated users only)
      get "/dashboard", PageController, :dashboard
      
      # Dynamic Survey Management (admin)
      live "/surveys/:id/builder", SurveyLive.Builder, :edit
      live "/surveys/builder/new", SurveyLive.Builder, :new
      live "/surveys/:id/analytics", SurveyLive.Analytics, :show
    end
  end
  
  # Public Survey Taking Routes (no authentication required)
  scope "/", CeecWeb do
    pipe_through [:browser]
    
    live_session :public_surveys,
      on_mount: [{CeecWeb.UserAuth, :mount_current_user}] do
      # Public survey taking interface
      live "/surveys/:id/take", SurveyLive.Take, :take
      live "/surveys/:id/completed", SurveyLive.Take, :completed
      
      # Loan-specific survey links
      live "/loans/:loan_id/survey/:id", SurveyLive.Take, :take_for_loan
      live "/loans/:loan_id/survey", SurveyLive.Take, :take_for_loan_auto
    end
  end

  scope "/", CeecWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{CeecWeb.UserAuth, :mount_current_user}],
      layout: {CeecWeb.Layouts, :auth} do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
