# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a comprehensive Monitoring and Evaluation (M&E) data collection platform built with Elixir/Phoenix and LiveView. The system enables funding organizations to track project performance, collect field data, manage beneficiaries, and generate M&E reports.

## Common Development Commands

### Setup and Dependencies
```bash
mix setup                    # Install dependencies, setup database, build assets
mix deps.get                # Install/update Elixir dependencies
mix ecto.setup              # Create database, run migrations, seed data
mix ecto.reset              # Drop and recreate database
```

### Development Server
```bash
mix phx.server              # Start Phoenix server (http://localhost:4000)
iex -S mix phx.server       # Start server with interactive Elixir shell
```

### Database Management
```bash
mix ecto.create             # Create database
mix ecto.migrate            # Run migrations
mix ecto.rollback           # Rollback last migration
mix ecto.gen.migration name # Generate new migration
```

### Testing
```bash
mix test                    # Run all tests
mix test test/path/file.exs # Run specific test file
mix test --trace            # Run tests with detailed output
mix test.watch              # Run tests in watch mode (if available)
```

### Code Quality
```bash
mix format                  # Format Elixir code
mix format --check-formatted # Check if code is formatted
```

### Assets
```bash
mix assets.setup            # Install frontend dependencies
mix assets.build            # Build assets for development
mix assets.deploy           # Build and minify assets for production
```

## Architecture Overview

### Domain Contexts (lib/ceec/)
- **Accounts** - User management, authentication, registration
- **Projects** - Project lifecycle, beneficiary tracking, progress monitoring
- **Finance** - Loan management, financial tracking, budget monitoring
- **Forms** - Dynamic form building and management
- **Surveys** - Survey creation, responses, analytics (legacy and dynamic)
- **MeData** - M&E data collection and processing
- **DataCollection** - Field data collection workflows

### Web Layer (lib/ceec_web/)
- **LiveView** - Interactive components for real-time updates
- **Controllers** - Traditional Phoenix controllers for specific workflows
- **Components** - Reusable UI components
- **Router** - Handles authentication pipelines and route organization

### Key Features
- **Multi-role Authentication** - Collectors, supervisors, administrators
- **Offline-capable** - Data collection works without internet connectivity
- **Form Builder** - Dynamic form creation with custom validation
- **Project Management** - Comprehensive project tracking with progress monitoring
- **Financial Integration** - Loan management and budget tracking
- **Reporting & Analytics** - Real-time dashboards and custom report generation

## Database

- **Primary Database**: PostgreSQL
- **ORM**: Ecto
- **Migrations**: Located in `priv/repo/migrations/`
- **Seeds**: `priv/repo/seeds.exs`

## Authentication & Authorization

The system uses Phoenix's built-in authentication with:
- Email/password authentication
- Session-based auth with secure tokens
- Role-based access control
- Public and authenticated route pipelines

### Route Structure
- **Public**: Loan applications, survey taking, status checking
- **Authenticated**: Dashboard, project management, admin functions
- **Admin Only**: User management, system settings, loan approvals

## Frontend Stack

- **Framework**: Phoenix LiveView with server-side rendering
- **CSS**: Tailwind CSS
- **Icons**: Heroicons
- **JavaScript**: Minimal ES6 with Phoenix hooks
- **Build Tools**: esbuild and Tailwind CLI

## Development Guidelines

### Context Boundaries
Each domain context should be self-contained with clear boundaries:
- Use contexts for business logic, not controllers
- Keep LiveView focused on user interaction
- Maintain schema relationships through proper associations

### LiveView Patterns
- Use `handle_event` for user interactions
- Implement `handle_info` for real-time updates
- Leverage `assign` for state management
- Use components for reusable UI elements

### Database Best Practices
- Always create reversible migrations
- Use constraints and indexes appropriately
- Implement proper foreign key relationships
- Consider data privacy in M&E contexts

### Testing Strategy
- Context functions should have comprehensive unit tests
- LiveView interactions should be tested with `Phoenix.LiveViewTest`
- Database operations should use sandbox mode
- Test both success and error scenarios

## Key Files and Directories

- `lib/ceec/` - Business logic contexts
- `lib/ceec_web/` - Web interface layer
- `priv/repo/migrations/` - Database migrations
- `test/` - Test suites organized by context
- `assets/` - Frontend assets (CSS, JS)
- `config/` - Application configuration
- `.formatter.exs` - Code formatting rules

## Configuration Notes

### Development
- Database runs on localhost:5432 with credentials in `config/dev.exs`
- Server runs on localhost:4000
- Live reload enabled for templates and assets
- Debug logging enabled

### Environment Variables
The application expects standard Phoenix/Ecto environment variables for production deployment.

## Domain-Specific Considerations

### M&E Data Requirements
- GPS coordinates for field visits
- File upload capabilities for evidence
- Multi-language form support
- Offline data synchronization
- Data validation and quality control workflows

### Financial Data
- Loan portfolio tracking
- Repayment schedules
- Financial performance indicators
- Integration between projects and loans

### User Roles
- **Collectors**: Field data collection
- **Supervisors**: Data validation and approval
- **Administrators**: System management and reporting
- **Public Users**: Survey responses and loan applications