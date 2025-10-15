# M&E Data Collection System

A comprehensive Monitoring and Evaluation (M&E) data collection platform designed for funding organizations to systematically track the performance, impact, and outcomes of funded projects.

## Purpose

This system enables organizations to:
- **Monitor Project Performance**: Track progress against key performance indicators
- **Evaluate Impact**: Assess the effectiveness and impact of funded interventions
- **Collect Field Data**: Support both online and offline data collection by field teams
- **Manage Beneficiaries**: Track project beneficiaries and their outcomes over time
- **Generate Reports**: Create comprehensive M&E reports and analytics
- **Ensure Data Quality**: Maintain data integrity with validation and verification

## Core Features

### Data Collection
- **Dynamic Forms**: Customizable form builder for different project types
- **Mobile-Friendly Interface**: Optimized for tablets and smartphones
- **Offline Capability**: Collect data without internet connection, sync when online
- **GPS Tracking**: Automatic location capture for field visits
- **File Uploads**: Support for photos, documents, and other attachments
- **Multi-language Support**: Collect data in local languages

### Project Management
- **Project Tracking**: Monitor multiple funded projects simultaneously
- **Beneficiary Database**: Comprehensive beneficiary information management
- **Timeline Management**: Track project milestones and evaluation schedules
- **Financial Tracking**: Monitor budget utilization and financial outcomes

### Reporting & Analytics
- **Real-time Dashboards**: Live project performance monitoring
- **Custom Reports**: Generate tailored M&E reports
- **Data Visualization**: Charts, graphs, and maps for data analysis
- **Export Capabilities**: Export data in various formats (Excel, PDF, etc.)
- **Impact Analysis**: Statistical analysis of project outcomes

### User Management
- **Role-based Access**: Different permissions for collectors, supervisors, administrators
- **Field Team Management**: Assign data collectors to specific projects/areas
- **Data Quality Control**: Review and validation workflows

## Typical M&E Data Collection Workflow

1. **Project Setup**: Create project profiles with objectives, indicators, and timelines
2. **Form Design**: Build custom data collection forms using the form builder
3. **Field Deployment**: Assign data collectors to projects and geographical areas
4. **Data Collection**: Field teams collect data using mobile devices (online/offline)
5. **Data Validation**: Supervisors review and validate collected data
6. **Analysis & Reporting**: Generate insights through dashboards and custom reports
7. **Impact Assessment**: Evaluate project outcomes and impact

## Data Collection Areas

The system supports various M&E data collection scenarios:

### Baseline Studies
- Pre-intervention data collection
- Beneficiary profiling and demographics
- Socio-economic indicators
- Infrastructure assessments

### Progress Monitoring
- Activity implementation tracking
- Output measurement
- Budget utilization monitoring
- Milestone achievement

### Outcome Evaluation
- Beneficiary impact assessment
- Behavioral change measurement
- Skills development tracking
- Income and livelihood improvements

### Financial Monitoring
- Loan portfolio management
- Repayment tracking
- Financial inclusion metrics
- Business growth indicators

## Setup

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Technology Stack

- **Backend**: Elixir/Phoenix Framework
- **Database**: PostgreSQL with PostGIS for location data
- **Frontend**: Phoenix LiveView with Tailwind CSS
- **File Storage**: Local storage with cloud backup options
- **Maps**: OpenStreetMap integration for location services
