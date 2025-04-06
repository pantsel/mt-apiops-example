# MT-APIOps Example

This repository contains an example of API Operations (APIOps) implementation using Kong Gateway and related tools. It demonstrates best practices for API management, documentation, and automation.

## Project Structure

```
.
├── .github/                           # GitHub Actions workflows and custom actions
│   ├── actions/                       # Custom GitHub Actions
│   │   └── load-env/                  # Environment loading action
│   └── workflows/                     # CI/CD workflow definitions
│       └── build-deploy.yaml          # Build and deploy workflow
├── apis/                              # API definitions and documentation
│   ├── flights/                       # Flight-related API endpoints
│   │   └── v1/                        # Version 1 of the Flights API
│   │       ├── openapi.yaml           # OpenAPI specification
│   │       └── kong/                  # Kong-specific configurations
│   │           └── plugins/           # API-specific plugins
│   └── routes/                        # Route-related API endpoints
│       └── v1/                        # Version 1 of the Routes API
│           ├── openapi.yaml           # OpenAPI specification
│           └── kong/                  # Kong-specific configurations
│               └── plugins/           # API-specific plugins
├── entities/                          # Entity definitions
│   └── tripwhiz/                      # TripWhiz entity configuration
│       ├── environments/              # Environment-specific configurations
│       │   ├── development/           # Development environment
│       │   ├── acceptance/            # Acceptance environment
│       │   └── production/            # Production environment
│       │       ├── env.sh             # Entity environment specific variables
│       │       └── metadata.json      # Entity metadata
│       ├── kong/                      # Entity-specific Kong configurations
│       │   ├── plugins/               # Entity-level plugins
│       │   └── patches/               # Entity-level patches
│       ├── env.sh                     # Common environment variables
├── governance/                        # Governance configuration
│   ├── kong/                          # Kong Gateway configuration
│   │   ├── plugins/                   # Governance-level plugins
│   │   └── patches/                   # Governance-level patches
│   ├── kong.ruleset.yaml              # Kong configuration specific rules
│   └── openapi.ruleset.yaml           # OpenAPI validation rules
├── .generated/                        # Placeholder for generated configuration files in the CI/CD pipeline
└── .gitignore                         # Git ignore rules
```

## API Documentation

The project includes two APIs:

- **Flights API**: Handles flight-related operations
- **Routes API**: Manages route-related operations

Each API is documented using OpenAPI specifications and defines API level plugins and patches.

## CI/CD

The project uses GitHub Actions for continuous integration and deployment. The workflows are defined in the `.github/workflows` directory and include:

### Build and Deploy Workflow (`build-deploy.yaml`)
The build and deploy workflow handles the build and deployment of API configurations to Konnect Control Planes.

- **Trigger**: Manual workflow dispatch
- **Inputs**:
  - `entity`: The entity to build configuration for (e.g., tripwhiz)
  - `environment`: Target environment (development/acceptance/production)
  - `show-summary`: Optional boolean to show build and deploy summary (default: true)
- **Jobs**:
  1. `get-apis`: Retrieves enabled APIs from entity metadata for the specified environment
  2. `build`: Matrix job that for each API:
     - Sets up environment variables using the `load-env` action
     - Lints OpenAPI specifications using governance rules
     - Converts OpenAPI specs to Kong declarative config
     - Adds API-specific plugins
     - Adds entity-level plugins and patches
     - Applies namespace configurations if required
     - Adds tags
     - Validates and renders Kong configurations
     - Uploads generated artifacts
  3. `combine`: Merges all API configurations:
     - Downloads all API artifacts
     - Merges configurations into a single file
     - Applies governance plugins and patches
     - Validates and lints combined configuration
     - Shows configuration preview and diff in summary (if show-summary is enabled)
     - Uploads combined configuration
  4. `deploy`: Deploys the combined configuration:
     - Downloads combined configuration
     - Creates backup of current Kong Gateway configuration (with generated_by:apiops tag)
     - Syncs new configuration to Kong Gateway
     - Waits for changes to propagate
     - Tests the API
     - Reverts to backup if sync or tests fail
     - Creates and uploads recent backup on success

### Environment Support
The workflows support multiple environments:
- Development (development)
- Acceptance (acceptance)
- Production (production)

### Security and Reliability
- Uses GitHub Secrets for sensitive information
- Implements environment-specific configurations via `load-env` action
- Validates API specifications before deployment
- Creates tagged backups before deployment
- Implements automatic rollback on failure
- Uses governance rules for validation
  - `governance/kong.ruleset.yaml`: Defines Kong-configuration specific rules and policies
  - `governance/openapi.ruleset.yaml`: Contains OpenAPI validation rules
- Supports optional configuration preview and diff review
- Maintains backup history with generated_by:apiops tag

### Build and Deploy Process Flow
```mermaid
graph TD
    A[Start] -->|Manual Trigger| B[get-apis]
    B -->|Get enabled APIs| C[build<br>API & Entity level Configs]
    C -->|Matrix Job| D[For each API]
    D -->|1| E[Setup & Load Env]
    D -->|2| F[Convert & Add Plugins]
    D -->|3| G[Add Patches & Namespace]
    D -->|4| H[Validate & Upload]
    H -->|All APIs| I[combine<br>Governance level Configs]
    I -->|1| J[Download Artifacts]
    I -->|2| K[Merge Configs]
    I -->|3| L[Apply Governance]
    I -->|4| M[Validate & Upload]
    M -->|Success| N[deploy]
    N -->|1| O[Download Config]
    N -->|2| P[Create Backup]
    N -->|3| Q[Sync to Gateway]
    Q -->|Success| R[Wait & Test]
    R -->|Success| S[Create & Upload Backup]
    R -->|Failure| T[Rollback]
    T -->|Restore| U[Previous Backup]
    S -->|Complete| V[End]
    U -->|Complete| V[End]

    style A fill:#666,stroke:#666,stroke-width:1px,color:#fff
    style V fill:#666,stroke:#666,stroke-width:1px,color:#fff
    style T fill:#666,stroke:#666,stroke-width:1px,color:#fff
    style S fill:#666,stroke:#666,stroke-width:1px,color:#fff
```