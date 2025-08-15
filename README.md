# JS Google Auth Lib Metadata Server Example

This repo demonstrates an issue with the Google Auth Lib. This significantly affects the performance of Claude Code
with Google Vertex.

In our environment, after a `gcloud auth application-default login`, this simple script (auth-test.cjs)
spends ~12 sec trying to connect to 169.254.169.254:80 (Google's metadata server) before eventually
succeeding.

```javascript
const { GoogleAuth } = require('google-auth-library')

async function main() {
  try {
    const authClient = await new GoogleAuth({
      scopes: 'https://www.googleapis.com/auth/cloud-platform',
    }).getClient()
    const authHeaders = await authClient.getRequestHeaders()
    console.log('Fetched headers')
  } catch (err) {
    console.error(err)
  }
}
main()
```

This is avoided if the Google SDK is logged in via **both**

1. login with `gcloud auth application-default login` **and**
2. lgoin with `gcloud auth login` **and**
3. set project with `gcloud config set project`.

The first login is necessary - without it claude code errors out. However, with just the first login, Claude Code is slow (~16 sec for a simple command).

After logging in with both and setting the project, test script is significantly faster.

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

