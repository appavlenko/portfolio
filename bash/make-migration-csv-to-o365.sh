#!/bin/sh

# Prompt user for login input
read -p "Enter login: " login

# Domain variables
olddomain="@"
newdomain="@"

# Default random password (consider using a secure method for production)
parandom="***"

echo 'Setting password...'

# Set the password for the user in the Zimbra system
zmprov sp "$login$olddomain" "$login$parandom"

echo 'Password has been set.'

echo 'Enabling SMTP access...'

# Enable IMAP for the user
zmprov ma "$login$olddomain" zimbraimapEnabled TRUE

echo 'SMTP access enabled.'

# Set the user description with another domain
zmprov ma "$login$olddomain" description "$newdomain"

# Enable mail forwarding and configure local delivery
zmprov ma "$login$olddomain" zimbraFeatureMailForwardingEnabled TRUE
zmprov ma "$login$olddomain" zimbraPrefMailLocalDeliveryDisabled TRUE

# Forward calendar invites to the specified email
zmprov ma "$login$olddomain" zimbraPrefCalendarForwardInvitesTo "$login$newdomain"

# Configure mail forwarding to the specified address
echo "Enabling mail forwarding to $login$newdomain"
zmprov ma "$login$olddomain" ZimbraPrefMailForwardingAddress "$login$newdomain"

# Generate a migration string for Office 365
now="$(date +'%Y-%m-%d-')"
migration_file="/tmp/$now$login.csv"

echo "Creating migration file for Office 365 at $migration_file"

# Prepare the CSV file with user credentials for migration
echo "EmailAddress,UserName,Password" >> "$migration_file"
echo "$login$newdomain,$login$olddomain,$login$parandom" >> "$migration_file"

# Set appropriate permissions on the migration file
chmod 777 "$migration_file"

echo "Migration file created and permissions set."
