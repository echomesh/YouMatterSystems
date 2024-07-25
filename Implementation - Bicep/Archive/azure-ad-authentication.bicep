param applicationDisplayName string = 'YouMatter PAS App'
param applicationIdentifierURI string = 'https://youmatter.systems/pas'
param replyURLs array = [
  'https://yourapp.youmatter.systems/auth/callback'
]

resource azureAdApp 'Microsoft.Graph/applications@1.0' = {
  name: applicationDisplayName
  properties: {
    displayName: applicationDisplayName
    signInAudience: 'AzureADMyOrg'
    identifierUris: [
      applicationIdentifierURI
    ]
    keyCredentials: [
      {
        customKeyIdentifier: '5EEA05A31639DE33529A908A5947D2BE9D1BED03',
        keyId: '5EEA05A31639DE33529A908A5947D2BE9D1BED03',
        type: 'AsymmetricX509Cert',
        usage: 'Verify',
        key: 'MIIDEjCCAfqgAwIBAgIQPeAo0WzEgK5JddNT55trADANBgkqhkiG9w0BAQUFADAcMRowGAYDVQQDDBFZb3VNYXR0ZXIgUEFTIEFwcDAeFw0yNDA3MjUwNjM0MzJaFw0yNTA3MjUwNjQ0MzJaMBwxGjAYBgNVBAMMEVlvdU1hdHRlciBQQVMgQXBwMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAszX9JhoY74rXqOxhl2L/OeER1bz6HD7w+dAhgZ9iZ+d+JMk4BuM/NjNcZop3MKvxKTre7gkChPCgSgRI/WknWf83lNTazsopsxL/FweGG38O9oy+8RSAIRHFsxFxcJ3To1onz/ZdbY/omN0qZDWFJ2Sgtyblqo6/QDVfhAon0I8J+Y70sSR5x77efPMuIzDf3OigZUNRp5E237/GQTc+VFFLt6XorV5orQwBnGaziPHiAerDIkIe6KmuN5Jqgdn8lLK8H0USLgEah+KLpJcIkPUqmja/pclE2Hy6iAphq4w+my+GPT1um1P0slVah4GXfRpvQMl3yc0cC1YAo0p88QIDAQABo1AwTjAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMBMB0GA1UdDgQWBBRYsvFxi4E/t7FrwoGd20i7Er5jaDANBgkqhkiG9w0BAQUFAAOCAQEAoYMncXgq58RaibSZEVxnoTV7irAJ1IDbIW1Mnm3N/GR2KkEYwJz5oSY0rnr6VoM2A3DZo1auu7cWKvl1vO5/YdrHGkWvP/2WBbhBCiynG/OVhva/ohaWdTphIvZ11VUeRP1lbxIQWGuuJP08Uw+KAA+Z68YbKvEPq3XHz+hHmNZTU3qyEp+nc+pI+tWG98lb4vWptok1ZfUK+ESY4FQeAIUMfsB045mxGtWq7xoMP6zb2+mmHEAnqW/rNOrO4qIEG+3NHh6NkiEc1HzbF84FCVxCrKClsdzXBh2ZG7CP2zaNLh2G+XxJrz4ADye1dAKaXrvUPGb3gRhc7H9f/y8gbA== '
      }
    ]
    web: {
      redirectUris: replyURLs
    }
  }
}
