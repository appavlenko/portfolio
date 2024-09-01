# Set admin username and password
$Admin = "***"
$PWord = ConvertTo-SecureString -String "***" -AsPlainText -Force

# Convert password to secure string
$password = ConvertTo-SecureString "***" -AsPlainText -Force

# Create a credential object for the techsender account
$credential = New-Object System.Management.Automation.PsCredential("techsender", $password)

# Create a credential object for the admin account
$UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Admin, $PWord

# Connect to Exchange Online and MSOL services
Connect-ExchangeOnline -Credential $UserCredential
Connect-MsolService -Credential $UserCredential

# Retrieve Office 365 E1 licenses and calculate available and total units
$Office365E1Licenses = Get-MsolAccountSku | Where-Object { $_.AccountSkuId -eq "reseller-account:STANDARDPACK" }
$Office365E1LicensesAvailable = $Office365E1Licenses.ActiveUnits - $Office365E1Licenses.ConsumedUnits
$Office365E1Total = $Office365E1Licenses.ActiveUnits

# Retrieve Office 365 Business Premium licenses and calculate available and total units
$Office365BPLicenses = Get-MsolAccountSku | Where-Object { $_.AccountSkuId -eq "reseller-account:O365_BUSINESS_PREMIUM" }
$Office365BPLicensesAvailable = $Office365BPLicenses.ActiveUnits - $Office365BPLicenses.ConsumedUnits
$Office365BPTotal = $Office365BPLicenses.ActiveUnits

# Retrieve Office 365 Business Essentials licenses and calculate available and total units
$Office365BELicenses = Get-MsolAccountSku | Where-Object { $_.AccountSkuId -eq "reseller-account:O365_BUSINESS_ESSENTIALS" }
$Office365BELicensesAvailable = $Office365BELicenses.ActiveUnits - $Office365BELicenses.ConsumedUnits
$Office365BETotal = $Office365BELicenses.ActiveUnits

# Create an HTML table for the email body
$EmailBody = @"
<table style="height: 218px; width: 771px; border-color: black; background-color: light;" border="1">
    <tbody>
        <tr>
            <td style="width: 95.8125px;">&nbsp;</td>
            <td style="width: 215.406px; text-align: center;"><span style="background-color: #ffffff; color: #000000;"><strong>E1</strong></span></td>
            <td style="width: 215.688px; text-align: center;"><span style="background-color: #ffffff; color: #000000;"><strong>Business Premium</strong></span></td>
            <td style="width: 216.094px; text-align: center;"><span style="background-color: #ffffff; color: #000000;"><strong>Business Essential</strong></span></td>
        </tr>
        <tr>
            <td style="width: 95.8125px; text-align: center;">Available</td>
            <td style="width: 215.406px; text-align: center;">$Office365E1LicensesAvailable</td>
            <td style="width: 215.688px; text-align: center;">$Office365BPLicensesAvailable</td>
            <td style="width: 216.094px; text-align: center;">$Office365BELicensesAvailable</td>
        </tr>
        <tr>
            <td style="width: 95.8125px; text-align: center;">Total</td>
            <td style="width: 215.406px; text-align: center;">$Office365E1Total</td>
            <td style="width: 215.688px; text-align: center;">$Office365BPTotal</td>
            <td style="width: 216.094px; text-align: center;">$Office365BETotal</td>
        </tr>
    </tbody>
</table>
"@

# Specify the SMTP server
$PSEmailServer = "*"

# Send the email with the Office 365 license report
Send-MailMessage -Credential $credential -From "techsenderemail" -To "email" -Subject "Office 365 License Report" -Body $EmailBody -BodyAsHtml
