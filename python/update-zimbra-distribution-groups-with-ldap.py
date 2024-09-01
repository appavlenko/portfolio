#!/usr/bin/python
# -*- coding: utf-8 -*-

import ldap
import sys
import os
import subprocess
from datetime import datetime

# LDAP server configuration
ldapHost = "ldap://your.ldap.server:port"
user = "YourUser@domain.com"
password = "YourPassword"
baseDN = "DC=example,DC=com"
searchScope = ldap.SCOPE_SUBTREE

# Zimbra configuration
fqdn = "yourdomain.com"
pathtozmprov = "/opt/zimbra/bin/zmprov"
tmppath = "/opt/zimbra/scripts/temp/groups/"

# Log file setup
cur_date = datetime.now().strftime("%Y-%m-%d")
logfile = os.path.join(tmppath, f"log/import_{cur_date}.log")

with open(logfile, 'a+') as f:
    f.write(f"{datetime.now()}\n")

# Command to retrieve distribution lists
if len(sys.argv) < 2:
    FirstExec = f"{pathtozmprov} gadl > {tmppath}distlist.tmp"
else:
    DL_mail = sys.argv[1]
    FirstExec = f"echo {DL_mail} > {tmppath}distlist.tmp"

os.system(FirstExec)

# Process each distribution list
for line in open(os.path.join(tmppath, "distlist.tmp")):
    zimbra_list = []
    StripLine = line.strip()
    populate_del_group = f"{pathtozmprov} rdlm {StripLine}"
    ExecGrouptoFile = f"{pathtozmprov} gdl {StripLine} > {tmppath}{StripLine}"

    os.system(ExecGrouptoFile)
    print(StripLine)

    Distr_Name = ""
    finded_mail = ""
    finded_mails = ""

    for line in open(os.path.join(tmppath, StripLine)):
        Line_parts = line.split()
        if len(Line_parts) > 0:
            if Line_parts[0] == "cn:":
                Distr_Name = line.split(" ", 1)[1].rstrip()
                print(f"Distr_Name = {Distr_Name}")
            elif Line_parts[0] == "zimbraMailForwardingAddress:":
                finded_mail = Line_parts[1].lower()
                zimbra_list.append(finded_mail)
                finded_mails += f" {finded_mail}"

    Distr_Name = Distr_Name.replace("(", "\(").replace(")", "\)")

    searchFilter = f'(&(objectClass=group)(cn={Distr_Name})(mail={StripLine}))'
    
    try:
        l = ldap.initialize(ldapHost)
        l.simple_bind_s(user, password)
        result = l.search_s(baseDN, searchScope, searchFilter)
    except ldap.LDAPError as error_message:
        with open(logfile, 'a+') as f:
            f.write(f'ERROR: {error_message}\n')
        print("Break")
        print(error_message)
        break

    if result:
        AD_list = []

        for (dn, vals) in result:
            try:
                member = vals['member']
            except KeyError:
                with open(logfile, 'a+') as f:
                    f.write(f'No users in group {StripLine}\n')
            
            for z in member:
                searchFilter = f"(&(distinguishedName={z})(!(useraccountcontrol:1.2.840.113556.1.4.803:=2)))"
                result_mail = l.search_s(baseDN, searchScope, searchFilter)

                if str(result_mail) != "[]":
                    for (dn, vals) in result_mail:
                        FindType = ''
                        for objectClass in vals['objectClass']:
                            if objectClass == "user" or objectClass == "contact":
                                FindType = 'user'
                            elif objectClass == "group":
                                FindType = 'group'
                        
                        if FindType == 'user':
                            try:
                                mail = vals['mail'][0].lower()
                                AD_list.append(mail)
                            except KeyError:
                                mail = ""
                                break
                        elif FindType == 'group':
                            subgroup = l.search_s(baseDN, searchScope, f"(distinguishedName={dn})")
                            for (dng, valsg) in subgroup:
                                try:
                                    mail = valsg['mail'][0].lower()
                                    AD_list.append(mail)
                                except KeyError:
                                    for groupmember in vals['member']:
                                        try:
                                            searchmem = l.search_s(baseDN, searchScope, f"(distinguishedName={groupmember})")
                                            for (dn5, vals5) in searchmem:
                                                try:
                                                    mail = vals5['mail'][0].lower()
                                                    AD_list.append(mail)
                                                except KeyError:
                                                    mail = ""
                                                    break
                                        except ldap.LDAPError:
                                            break

        zimbra_set = set(zimbra_list)
        AD_set = set(AD_list)
        
        set_to_add_mails = AD_set.difference(zimbra_set)
        set_to_delete_mails = zimbra_set.difference(AD_set)

        list_to_add = list(set_to_add_mails)
        list_to_del = list(set_to_delete_mails)

        if list_to_add:
            add_group = " ".join(list_to_add)
            string_add_to_group = f"{pathtozmprov} adlm {StripLine} {add_group}"
            with open(logfile, 'a+') as f:
                f.write(f'Add mail to Group {string_add_to_group}\n')
            subprocess.call(string_add_to_group, shell=True)

        if list_to_del:
            del_group = " ".join(list_to_del)
            string_del_from_group = f"{pathtozmprov} rdlm {StripLine} {del_group}"
            with open(logfile, 'a+') as f:
                f.write(f'Del mail from Group {string_del_from_group}\n')
            subprocess.call(string_del_from_group, shell=True)

        exectomove = f"mv -f {os.path.join(tmppath, StripLine)} {os.path.join(tmppath, 'old', StripLine)}"
        os.system(exectomove)

    else:
        with open(logfile, 'a+') as f:
            f.write(f'Zimbra Group {StripLine} not found in AD\n')

    l.unbind_s()

with open(logfile, 'a+') as f:
    f.write(f"{datetime.now()}\n")
    f.write('=' * 80 + '\n')
