#!/bin/bash

# Directories and files
curdir=/opt/zimbra/scripts/helpfull
temp_dir=/opt/zimbra/scripts/helpfull/temp
userlist=$temp_dir/userlist.txt
fulluserlist=$temp_dir/fulluserlist.txt

# Retrieve full user list with details from the domain and save it to a file
zmprov -l gaa -v badm.biz > $fulluserlist

# Initialize variables for account details
email=''
login_name=''
last_name=''
first_name=''
sec_name=''
last_login=''
login_status=''
forward_mail=''
description_mail=''
date_create=''
mbx_size=''
zimbra_notes=''

# Prepare the output file
echo '' > $temp_dir/acc_info.txt

# Process each line of the full user list
cat $fulluserlist | while read line; do
    ll=($line)
    lenline=${#line}

    # Check if the line is not empty
    if [ $lenline != 0 ]; then
        # If the line starts with "# name", it indicates the start of a new account section
        if [ "${ll[0]}" == "#" ] && [ "${ll[1]}" == "name" ]; then
            # Save the collected data to the output file
            echo "$email;$login_name;$last_name;$first_name;$sec_name;$date_create;$last_login;$login_status;$description_mail;$forward_mail;$mbx_size;$zimbra_notes" >> $temp_dir/acc_info.txt
            
            # Reset the variables for the next account
            email=''
            login_name=''
            last_name=''
            first_name=''
            sec_name=''
            last_login=''
            login_status=''
            forward_mail=''
            description_mail=''
            date_create=''
            mbx_size=''
            zimbra_notes=''

        else
            # Extract and assign values based on specific keys
            case ${ll[0]} in
                "givenName:")
                    first_name=${ll[1]}
                    ;;
                "initials:")
                    sec_name=${ll[1]}
                    ;;
                "sn:")
                    last_name=${ll[1]}
                    ;;
                "zimbraMailDeliveryAddress:")
                    email=${ll[1]}
                    ;;
                "zimbraAuthLdapExternalDn:")
                    login_name=${ll[1]}
                    ;;
                "zimbraLastLogonTimestamp:")
                    last_login=${ll[1]}
                    ;;
                "zimbraAccountStatus:")
                    login_status=${ll[1]}
                    ;;
                "zimbraPrefMailForwardingAddress:" | "zimbraMailForwardingAddress:")
                    forward_mail=${ll[1]}
                    ;;
                "description:")
                    description_mail=${ll[1]}
                    ;;
                "zimbraNotes:")
                    zimbra_notes=${ll[1]}
                    ;;
                "zimbraMailAlias:")
                    mbx_size=${ll[1]}
                    ;;
                "zimbraCreateTimestamp:")
                    date_create=${ll[1]}
                    ;;
            esac
        fi
    fi
done
