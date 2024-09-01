#!/bin/bash

# Filename for the report
report_filename='zimbra_mailbox_report.csv'

# Initialize the CSV file with headers
echo "Email,Size,Date Created,Last Login,Forwarding Address,Login" > $report_filename

# Get all accounts in Zimbra
all_accounts=$(zmprov -l gaa)

# Loop through each account to gather information
for account in $all_accounts; do
    echo "============================================"
    echo "Processing mailbox: $account"

    # Get mailbox size
    mb_size=$(zmmailbox -z -m $account gms)
    echo "Mailbox size: $mb_size"

    # Get detailed account information
    mailbox_info=$(zmprov ga $account)

    # Initialize variables for the report
    size=$mb_size
    date_created=""
    last_login=""
    forwarding_address=""
    login=$account

    # Extract necessary details from mailbox information
    while IFS= read -r line; do
        case $line in
            "createDate:"*)
                date_created=$(echo $line | cut -d ':' -f 2 | tr -d ' ')
                ;;
            "zimbraLastLogonTimestamp:"*)
                last_login=$(echo $line | cut -d ':' -f 2 | tr -d ' ')
                ;;
            "zimbraMailForwardingAddress:"*)
                forwarding_address=$(echo $line | cut -d ':' -f 2 | tr -d ' ')
                ;;
        esac
    done <<< "$mailbox_info"

    # Append the collected data to the CSV report
    echo "$account,$size,$date_created,$last_login,$forwarding_address,$login" >> $report_filename
done

# Notify that the report has been saved
echo "Report saved in '$report_filename'."
