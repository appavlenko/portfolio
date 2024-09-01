$inputFile = "*\ping.txt" 
$outputFile = "*\pinpresult.csv" 
$devices = Get-Content $inputFile 
$results = @() 
foreach ($device in $devices) { 
    try { 
        $pingResult = Test-Connection -ComputerName $device -Count 1 -BufferSize 32 -ErrorAction SilentlyContinue 
        $status = if ($pingResult) { "Available" } else { "Unavailable" } 
    } catch { 
        $status = "Unavailable" 
    } 
    $result = [PSCustomObject]@{ 
        Device = $device 
        Status = $status 
    } 
    $results += $result 
} 
$results | Export-Csv -Path $outputFile -NoTypeInformation 
