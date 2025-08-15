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
