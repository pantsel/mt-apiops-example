# MT-APIOps Example

This repository contains an example of API Operations (APIOps) implementation using Kong Gateway and related tools. It demonstrates best practices for API management, documentation, and automation.

## Project Structure

```
.
├── apis/                          # API definitions and documentation
│   ├── flights/                   # Flight-related API endpoints
│   │   └── v1/                   # Version 1 of the Flights API
│   │       ├── openapi.yaml      # OpenAPI specification
│   │       └── kong/            # Kong-specific configurations
│   │           └── plugins/     # API-specific plugins
│   └── routes/                   # Route-related API endpoints
│       └── v1/                   # Version 1 of the Routes API
│           ├── openapi.yaml      # OpenAPI specification
│           └── kong/            # Kong-specific configurations
│               └── plugins/     # API-specific plugins
├── entities/                     # Entity definitions
│   └── tripwhiz/                # TripWhiz entity configuration
│       ├── metadata.json        # Entity metadata
│       ├── kong/               # Entity-specific Kong configurations
│       │   ├── plugins/       # Entity-level plugins
│       │   └── patches/       # Entity-level patches
│       └── env.*.sh           # Environment-specific configurations
├── platform/                    # Platform configuration
│   ├── kong/                   # Kong Gateway configuration
│   │   └── patches/           # Platform-level patches
│   ├── kong.ruleset.yaml      # Kong-specific rules
│   └── openapi.ruleset.yaml   # OpenAPI validation rules
├── .github/                    # GitHub Actions workflows
│   └── workflows/             # CI/CD workflow definitions
│       └── build-deploy.yaml  # Build and deploy workflow
├── .deck.yaml                 # Deck configuration for Kong
├── .gitignore                 # Git ignore rules
└── act.secrets               # Local development secrets
```

## Prerequisites

- [Kong Gateway](https://konghq.com/kong/)
- [Deck](https://github.com/Kong/deck) - A declarative configuration tool for Kong
- [GitHub Actions](https://github.com/features/actions) (for CI/CD)

## Configuration

The project uses the following configuration files:

- `.deck.yaml`: Contains Kong Gateway configuration and authentication details
- `platform/kong.ruleset.yaml`: Defines Kong-specific rules and policies
- `platform/openapi.ruleset.yaml`: Contains OpenAPI validation rules

## Getting Started

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd mt-apiops-example
   ```

2. Configure your Kong Gateway credentials in `.deck.yaml`:
   ```yaml
   konnect-token: your-token
   konnect-addr: your-konnect-address
   ```

3. Apply the configuration to your Kong Gateway:
   ```bash
   deck sync
   ```

## API Documentation

The project includes two main API categories:

- **Flights API**: Handles flight-related operations
- **Routes API**: Manages route-related operations

Each API is documented using OpenAPI specifications and follows best practices for API design.

## CI/CD

The project uses GitHub Actions for continuous integration and deployment. The workflows are defined in the `.github/workflows` directory and include:

### Build and Deploy Workflow (`build-deploy.yaml`)
The build and deploy workflow handles the build and deployment of API configurations to Konnect Control Planes.

- **Trigger**: Manual workflow dispatch
- **Inputs**:
  - `entity`: The entity to build configuration for (e.g., tripwhiz)
  - `environment`: Target environment (development/acceptance/production)
- **Jobs**:
  1. `get-apis`: Retrieves enabled APIs from entity metadata for the specified environment
  2. `build`: Matrix job that for each API:
     - Sets up environment variables and Deck configuration
     - Lints OpenAPI specifications
     - Converts OpenAPI specs to Kong declarative config
     - Adds API-specific plugins
     - Adds entity-level plugins and patches
     - Applies namespace configurations
     - Adds tags
     - Validates and lints Kong configurations
     - Uploads generated artifacts
  3. `combine`: Merges all API configurations:
     - Downloads all API artifacts
     - Merges configurations into a single file
     - Applies governance patches
     - Validates and lints combined configuration
     - Shows configuration diff
     - Uploads combined configuration
  4. `deploy`: Deploys the combined configuration:
     - Downloads combined configuration
     - Creates backup of current Kong Gateway configuration
     - Syncs new configuration to Kong Gateway

### Environment Support
The workflows support multiple environments:
- Development (dev)
- Acceptance (acc)
- Production (prd)