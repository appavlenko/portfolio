# Set file paths for input (email addresses) and output (CSV report)
$filePath = "*\mail.txt"
$outputCsvFilePath = "*\mailandlicense.csv"

# Load email addresses from the input file
$emailAddresses = Get-Content $filePath

# Initialize an empty array to store results
$results = @()

# Connect to Azure AD
Connect-AzureAD

# Loop through each email address
foreach ($email in $emailAddresses) {
    # Get Azure AD user information based on the email address
    $user = Get-AzureADUser -Filter "UserPrincipalName eq '$email'"
    
    if ($user) {
        # If user is found, retrieve their licenses
        $userId = $user.ObjectId
        $licenses = Get-AzureADUserLicenseDetail -ObjectId $userId
        
        # Loop through each license and prepare the result
        foreach ($license in $licenses) {
            $result = New-Object PSObject -Property @{
                "EmailAddress" = $email
                "License" = $license.SkuPartNumber
            }
            # Add the result to the results array
            $results += $result
        }
    } else {
        # If user is not found, log the information
        Write-Host "Email $email not found in Azure AD."
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path $outputCsvFilePath -Encoding UTF8 -NoTypeInformation
Disconnect-AzureAD

