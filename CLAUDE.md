# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a test repository demonstrating performance issues with the Google Auth Library when connecting to Google's metadata server (169.254.169.254). The project uses a Docker-based testing environment to reproduce authentication delays that affect Claude Code's performance with Google Vertex AI.

## Architecture

The repository contains:
- **auth-test.cjs**: Simple Node.js test script that demonstrates the authentication delay
- **google-auth-library-nodejs/**: Complete source code of the Google Auth Library (cloned from GitHub main branch)
  - See [google-auth-library-nodejs/CLAUDE.md](google-auth-library-nodejs/CLAUDE.md) for detailed library architecture and development information
- **test.sh**: Bash script that orchestrates the authentication flow and testing
- **Dockerfile**: Alpine-based container with Node.js, gcloud CLI, and network debugging tools
- **Makefile**: Build and run automation with configurable environment variables

The Docker container builds and installs the Google Auth Library from source rather than using the npm package, allowing testing against the latest main branch code.

## Build and Run Commands

### Basic Usage
```bash
# Build the Docker image
make build

# Run the full test suite (requires interactive authentication)
make run

# Clean up
make clean

# Show help with all options
make help
```

### Environment Variables
Control test behavior with these variables:

```bash
# Set Google Cloud project ID (default: avalabs-sec-app-env)
make run GCLOUD_PROJECT_ID=your-project-id

# Skip specific authentication steps
make run SKIP_GCLOUD_AUTH_LOGIN=1
make run SKIP_GCLOUD_CONFIG_SET_PROJECT=1

# Skip the slow first test
make run SKIP_FIRST_TEST=1

# Run the test twice to compare performance
make run RUN_SLOW_TEST_AGAIN=1

# Include metadata server connectivity test
make run RUN_CURL_METADATA=1

# Enable network packet capture (saves to ./traces/)
make run TCPDUMP=1
```

### Network Debugging
When `TCPDUMP=1` is set, network packets are captured during each command and saved to timestamped files in the `./traces/` directory with the format: `YYYY-MM-DDTHH-MM-SSZ-<index>-<command>`.

## Test Flow

The test script (`test.sh`) performs these steps:
1. Optional: Test metadata server connectivity
2. Check gcloud version
3. Authenticate with `gcloud auth application-default login`
4. Set quota project for application default credentials
5. Run the auth test (slow on first run)
6. Optional: Run auth test again to compare performance
7. Optional: Authenticate with `gcloud auth login`
8. Optional: Set gcloud project configuration
9. Run final auth test (should be fast after full setup)

The key insight is that authentication performance improves significantly after completing all three setup steps: application-default login, user login, and project configuration.