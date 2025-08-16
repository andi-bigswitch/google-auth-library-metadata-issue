# JS Google Auth Lib Metadata Server Example

This repo demonstrates and analyzes a performance issue with the Google Auth Library for Node.js that significantly affects Claude Code when using Google Vertex AI.

## The Issue

After running `gcloud auth application-default login`, the Google Auth Library experiences a ~3 second delay on first authentication due to attempting to contact the GCE metadata server at `169.254.169.254:80` for project ID discovery, which times out in non-GCE environments.

## Root Cause

The Application Default Credentials (ADC) file created by `gcloud auth application-default login` contains `quota_project_id` but not `project_id`. The library needs a project ID and attempts discovery in this order:

1. Environment variables (`GOOGLE_CLOUD_PROJECT`, `GCLOUD_PROJECT`)
2. Credential file's `project_id` field (missing in ADC)
3. gcloud config via `gcloud config config-helper` (not set after ADC login only)
4. **GCE metadata server** (causes timeout in non-GCE environments)

## Quick Fix

Set the `GOOGLE_CLOUD_PROJECT` environment variable:
```bash
export GOOGLE_CLOUD_PROJECT=your-project-id
```

Or in code:
```javascript
const authClient = await new GoogleAuth({
  projectId: 'your-project-id',  // Explicitly provide project ID
  scopes: 'https://www.googleapis.com/auth/cloud-platform',
}).getClient()
```

## Complete Solution

For a complete gcloud setup that avoids the metadata server timeout:

1. `gcloud auth application-default login` - Creates ADC credentials
2. `gcloud auth login` - Authenticates user account
3. `gcloud config set project <project>` - Sets default project

After all three steps, the library can discover the project ID from gcloud configuration without attempting metadata server access.

## Detailed Analysis

For a comprehensive breakdown of the authentication flow, code references, and additional solutions, see [ANALYSIS.md](ANALYSIS.md).

## Instructions

After cloning this repository:

```bash
# Initialize the git submodule
make init

# Build and run the test
make build run
```

### Additional Options

```bash
# Show all available options and environment variables
make help

# Run with network packet capture
make run TCPDUMP=1

# Skip interactive authentication steps for automated testing
make run SKIP_GCLOUD_AUTH_LOGIN=1 SKIP_GCLOUD_CONFIG_SET_PROJECT=1

# Test with a different Google Cloud project
make run GCLOUD_PROJECT_ID=your-project-id
```

