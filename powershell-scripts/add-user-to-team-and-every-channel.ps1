# Set tenant ID, client ID, and client secret
$tenantId = "*"
$clientId = "*"
$clientSecret = "*"

# Prepare the request body for the token request
$body = @{ 
    grant_type    = "client_credentials" 
    scope         = "https://graph.microsoft.com/.default" 
    client_id     = $clientId 
    client_secret = $clientSecret 
}

# Get the access token
$tokenResponse = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -ContentType "application/x-www-form-urlencoded" -Body $body
$accessToken = $tokenResponse.access_token

# Set the team ID and user email
$teamId = "*"
$userEmail = "*"

# Retrieve user information using their email
$user = Invoke-RestMethod -Method Get -Uri "https://graph.microsoft.com/v1.0/users/$userEmail" -Headers @{Authorization = "Bearer $accessToken"}

# Prepare the request body to add the user as a team member
$body = @{ 
    "@odata.type" = "#microsoft.graph.aadUserConversationMember"
    roles         = @("member")
    "user@odata.bind" = "https://graph.microsoft.com/v1.0/users/$($user.id)"
}

# Add the user to the team
Invoke-RestMethod -Method Post -Uri "https://graph.microsoft.com/v1.0/teams/$teamId/members" -Headers @{Authorization = "Bearer $accessToken"} -ContentType "application/json" -Body ($body | ConvertTo-Json)
Write-Host "User $userEmail has been added to the team."

# Retrieve all channels for the team
$channels = Invoke-RestMethod -Method Get -Uri "https://graph.microsoft.com/v1.0/teams/$teamId/channels" -Headers @{Authorization = "Bearer $accessToken"}
$privateChannels = $channels.value | Where-Object { $_.membershipType -eq "private" }

# Iterate through private channels and add the user to each one
foreach ($channel in $privateChannels) {
    try {
        # Prepare the request body to add the user to the private channel
        $body = @{ 
            "@odata.type" = "#microsoft.graph.aadUserConversationMember"
            roles         = @("member")
            "user@odata.bind" = "https://graph.microsoft.com/v1.0/users/$($user.id)"
        }

        # Add the user to the private channel
        Invoke-RestMethod -Method Post -Uri "https://graph.microsoft.com/v1.0/teams/$teamId/channels/$($channel.id)/members" -Headers @{Authorization = "Bearer $accessToken"} -ContentType "application/json" -Body ($body | ConvertTo-Json)
        Write-Host "User $userEmail added to channel $($channel.displayName)."

    } catch {
        # Handle any errors
        Write-Host "Failed to add user to channel $($channel.displayName). Error: $_"
    }
}
