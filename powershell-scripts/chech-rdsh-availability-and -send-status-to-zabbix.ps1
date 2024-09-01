# This script checks the reachability of session hosts in Remote Desktop Services (RDS) collections on a specified connection broker.
# It excludes certain collections from the check, identifies collections where hosts are unreachable, and reports the results to Zabbix.
# The script specifically returns a negative value (bad status) if more than half of the hosts in any collection are unreachable.

# Retrieve the list of RDS collections from the specified connection broker
$RDSCollections = Get-RDSessionCollection -ConnectionBroker "your-connection-broker"

# Define collections to exclude from the check
$excludedCollections = @("excluded-collection")

# Initialize an array to store the names of unreachable collections
$unreachableCollections = @()

# Iterate through each RDS collection
foreach ($RDSCollection in $RDSCollections) {
    $CollectionName = $RDSCollection.CollectionName

    # Check if the collection is not in the excluded list
    if ($CollectionName -notin $excludedCollections) {

        # Get the session hosts for the collection
        $SessionHosts = Get-RDSessionHost -CollectionName $CollectionName -ConnectionBroker "your-connection-broker" | Select-Object -ExpandProperty SessionHost

        $totalHosts = $SessionHosts.Count
        $reachableHosts = 0

        # Check the reachability of each session host
        foreach ($SessionHost in $SessionHosts) {
            $hostReachable = Test-NetConnection -ComputerName $SessionHost -Port 3389 -WarningAction SilentlyContinue -InformationLevel Quiet
            if ($hostReachable) {
                $reachableHosts++
            } else {
                $unreachableCollections += $CollectionName
            }
        }

        # Determine if the collection is considered unreachable
        if ($reachableHosts -eq 0) {
            $unreachableCollections += $CollectionName
        } elseif ($totalHosts -eq 1 -and $reachableHosts -eq 0) {
            $unreachableCollections += $CollectionName
        } elseif ($totalHosts -gt 1 -and $reachableHosts -lt ($totalHosts / 2)) {
            $unreachableCollections += $CollectionName
        }
    }
}

# Send the result to Zabbix based on the reachability of the collections
if ($unreachableCollections.Count -eq 0) {
    & "C:\zabbix\bin\zabbix_sender.exe" -z zabbix-server -s "*" -k rdpcheck -o 1
} else {
    & "C:\zabbix\bin\zabbix_sender.exe" -z zabbix-server -s "*" -k rdpcheck -o 0
}
