#This script automates the process of assigning Office 365 licenses to new users in Azure AD
#Creating specific mail folders, and setting up inbox rules in their mailboxes. 
#It also generates and sends a report of the actions performed via email

# Variables for connection
$Admin = "your-admin-username"
$PWord = ConvertTo-SecureString -String "your-password" -AsPlainText -Force
$UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Admin, $PWord

$password = ConvertTo-SecureString "your-credential-password" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PsCredential("techsender", $password)

$PSEmailServer = "your-email-server"

# Variable for report body
$EmailBody = @"
<h1>License Assignment Report</h1>
"@

# Connect to various Microsoft services
Connect-ExchangeOnline -Credential $UserCredential
Connect-MsolService -Credential $UserCredential
Connect-AzureAD -Credential $UserCredential
Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All

# Get the list of newly created unlicensed users within the last 5 hours
$Userlist = (Get-MsolUser -UnlicensedUsersOnly | Where-Object {($_.WhenCreated -ge (Get-Date).AddHours(-5)) -and ($_.ImmutableId -ne $null)}).UserPrincipalName

# Check if any new users were found
if ($Userlist.Count -eq 0) {
    $EmailBody += "<p>No new users found.</p>"
    Send-MailMessage -Credential $credential -From "techsender@badm.biz" -To "recipient@domain.com" -Subject "No New Users Found" -Body $EmailBody -BodyAsHtml -Encoding ([System.Text.Encoding]::utf8)
    exit
}

# Retrieve the desired license SKU (Standard License)
$license = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "STANDARDPACK" }

# Function to assign licenses with retry logic
function Assign-Licenses {
    param (
        [string[]]$UserList,
        $License
    )

    $LicenseReport = @()

    foreach ($user in $UserList) {
        $maxAttempts = 6
        $attempt = 0
        $success = $false

        while (-not $success -and $attempt -lt $maxAttempts) {
            try {
                $graphUser = Get-MgUser -Filter "UserPrincipalName eq '$user'"

                # Set user location to UA if not already set
                if ($graphUser.UsageLocation -eq $null -or $graphUser.UsageLocation -ne "UA") {
                    Set-AzureADUser -ObjectId $graphUser.Id -UsageLocation "UA"
                    Write-Host "Set usage location for $($graphUser.UserPrincipalName)"
                }

                # Check if license is already assigned
                $userLicense = Get-MgUserLicenseDetail -UserId $graphUser.Id | Where-Object { $_.SkuId -eq $License.SkuId }
                if ($userLicense) {
                    Write-Host "License $($License.SkuPartNumber) is already assigned to $($graphUser.DisplayName)" -ForegroundColor Yellow
                    $LicenseReport += "License $($License.SkuPartNumber) is already assigned to $($graphUser.DisplayName)"
                    $success = $true
                } else {
                    Write-Host "Assigning license $($License.SkuPartNumber) to $($graphUser.DisplayName)" -ForegroundColor Green
                    Set-MgUserLicense -UserId $graphUser.Id -AddLicenses @{SkuId = ($License.SkuId)} -RemoveLicenses @() -ErrorAction Stop
                    $LicenseReport += "Assigned license $($License.SkuPartNumber) to $($graphUser.DisplayName)"
                    $success = $true
                }
            } catch {
                Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
                $LicenseReport += "An error occurred for ${user}: $($_.Exception.Message)"
                $attempt++
                Start-Sleep -Seconds 10
            }
        }

        if (-not $success) {
            Write-Host "Failed to assign license to $user after $maxAttempts attempts" -ForegroundColor Red
            $LicenseReport += "Failed to assign license to $user after $maxAttempts attempts"
        }
    }

    return $LicenseReport
}

# Assign licenses and generate a report
$LicenseReport = Assign-Licenses -UserList $Userlist -License $license

# Add license assignment report to the email body
$EmailBody += "<h2>License Assignment</h2><ul>"
foreach ($line in $LicenseReport) {
    $EmailBody += "<li>$line</li>"
}
$EmailBody += "</ul>"

# Pause before the next step
Write-Host "License assignment completed. Pausing for 150 seconds before proceeding." -ForegroundColor Cyan
Start-Sleep -Seconds 150

# Function to create mail folders for the user
function Create-MailFolders {
    param (
        [string]$Mailbox,
        $Header
    )

    # Define folder names and hierarchy
    $folderStructure = @{
        "Doc" = @("Portal", "Approves")
        "ITSM" = @("Tickets","HRM")
    }

    $FolderReport = @()

    # Create main folders
    foreach ($folderName in $folderStructure.Keys) {
        $uri = "https://graph.microsoft.com/v1.0/users/$Mailbox/mailFolders"
        $folder = @{ displayName = $folderName }
        $ParentFolder = Invoke-RestMethod -Uri $uri -Headers $Header -Method Post -Body ($folder | ConvertTo-Json) -ContentType "application/json;charset=utf-8"
        $FolderReport += "Created new folder: $($ParentFolder.displayName) in mailbox $Mailbox"
        
        # Create subfolders if applicable
        if ($folderStructure[$folderName]) {
            $parentFolderId = ($MailboxfoldersList | Where-Object { $_.displayName -eq "$folderName" }).id
            $uri = "https://graph.microsoft.com/v1.0/users/$Mailbox/mailFolders/$parentFolderId/childFolders"
            foreach ($subFolderName in $folderStructure[$folderName]) {
                $subFolder = @{ displayName = $subFolderName }
                $ParentFolder = Invoke-RestMethod -Uri $uri -Headers $Header -Method Post -Body ($subFolder | ConvertTo-Json) -ContentType "application/json;charset=utf-8"
                $FolderReport += "Created new folder: $($ParentFolder.displayName) in mailbox $Mailbox"
            }
        }
    }

    return $FolderReport
}

# Function to create inbox rules for the user
function Create-InboxRules {
    param (
        [string]$Mailbox
    )

    $RuleReport = @()

    # Add full access permissions temporarily
    Add-MailboxPermission -Identity $Mailbox -User admin@domain.com -AccessRights Fullaccess

    # Define and create rules
    $rules = @(
        @{Name="System - Portal"; Params=@{FromAddressContainsWords="portal@domain.com"; MoveToFolder=":\Doc\Portal"}},
        # Add additional rules here following the same pattern...
    )

    foreach ($rule in $rules) {
        try {
            New-InboxRule -Mailbox $Mailbox -Name $rule.Name @rule.Params -StopProcessingRules $true
            $RuleReport += "Created new rule: $($rule.Name) for mailbox $Mailbox"
        } catch {
            $RuleReport += "An error occurred for rule $($rule.Name): $($_.Exception.Message)"
        }
    }

    # Remove full access permissions
    Remove-MailboxPermission -Identity $Mailbox -User admin@domain.com -AccessRights Fullaccess -Confirm:$false

    return $RuleReport
}

# Get token for Graph API authentication
$AppId = "your-app-id"
$AppSecret = "your-app-secret"
$Scope = "https://graph.microsoft.com/.default"
$TenantName = "your-tenant-name.onmicrosoft.com"
$Url = "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token"

$Body = @{
    client_id = $AppId
    client_secret = $AppSecret
    scope = $Scope
    grant_type = 'client_credentials'
}

$PostSplat = @{
    ContentType = 'application/x-www-form-urlencoded'
    Method = 'POST'
    Body = $Body
    Uri = $Url
}

$Request = Invoke-RestMethod @PostSplat
$Header = @{
    Authorization = "$($Request.token_type) $($Request.access_token)"
}

# Execute folder and rule creation for each user
$FolderReports = @()
$RuleReports = @()

foreach ($user in $Userlist) {
    $graphUser = Get-MgUser -Filter "UserPrincipalName eq '$user'"

    # Create mail folders
    $FolderReport = Create-MailFolders -Mailbox $graphUser.UserPrincipalName -Header $Header
    $FolderReports += $FolderReport

    # Create inbox rules
    $RuleReport = Create-InboxRules -MAIL $graphUser.UserPrincipalName
    $RuleReports += $RuleReport
}

# Add folder creation report to the email body
$EmailBody += "<h2>Folder Creation</h2><ul>"
foreach ($line in $FolderReports) {
    $EmailBody += "<li>$line</li>"
}
$EmailBody += "</ul>"

# Add rule creation report to the email body
$EmailBody += "<h2>Rule Creation</h2><ul>"
foreach ($line in $RuleReports) {
    $EmailBody += "<li>$line</li>"
}
$EmailBody += "</ul>"

# Send the final report via email
Send-MailMessage -Credential $credential -From "techsender@domain.com" -To "recipient@domain.com" -Subject "License Assign Report" -Body $EmailBody -BodyAsHtml -Encoding ([System.Text.Encoding]::utf8)
