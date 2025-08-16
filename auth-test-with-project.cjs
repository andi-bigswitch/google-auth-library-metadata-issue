const { GoogleAuth } = require('google-auth-library')

async function main() {
  try {
    // Use project ID from environment variable if set
    const projectId = process.env.ANTHROPIC_VERTEX_PROJECT_ID
    
    const authOptions = {
      scopes: 'https://www.googleapis.com/auth/cloud-platform',
    }
    
    if (projectId) {
      console.log(`Using project ID from ANTHROPIC_VERTEX_PROJECT_ID: ${projectId}`)
      authOptions.projectId = projectId
    } else {
      console.log('No ANTHROPIC_VERTEX_PROJECT_ID set, letting library discover project')
    }
    
    const authClient = await new GoogleAuth(authOptions).getClient()
    const authHeaders = await authClient.getRequestHeaders()
    console.log('Fetched headers')
  } catch (err) {
    console.error(err)
  }
}
main()