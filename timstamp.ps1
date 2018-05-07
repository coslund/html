$eventlogs = Get-EventLog -LogName Security -InstanceId 4616 -Newest 10
$AllowedTimeJumpMinutes = 15

foreach ($eventlog in $eventlogs){
    $eventlog_filtered = $eventlog.Message.Split("`n") # | Where-Object {$_ -like "*Time*"} # potential further optimization

    $previous_datetime = $eventlog_filtered | Where-Object {$_ -like "*Previous Time*"}
    $previous_datetime = $previous_datetime.substring(16,19)
    $previous_datetime = [datetime]::ParseExact($previous_datetime,'yyyy-MM-ddTHH:mm:ss',$null)
    $previous_datetime

    $new_datetime = $eventlog_filtered | Where-Object {$_ -like "*New Time*"}
    $new_datetime = $new_datetime.substring(11,19)
    $new_datetime = [datetime]::ParseExact($new_datetime,'yyyy-MM-ddTHH:mm:ss',$null)
    $new_datetime

    $time_span_raw = New-TimeSpan -Start $previous_datetime -End $new_datetime
    
    if ($time_span_raw -lt 0 ) { #ABS function - alert on a forward jump too
    		$time_span = $time_span_raw.Negate()
    		} else {
    		$time_span = $time_span_raw
    }
    
    $date_compare = New-TimeSpan -Start $(Get-Date).AddMinutes(-$AllowedTimeJumpMinutes) -End $(Get-Date)

    if ($time_span -gt $date_compare){
        $CanaryErrors++
        Write-Host "Time reversal was $($time_span_raw.TotalMinutes) minutes"
        Write-Host "Time test: FAIL"
    }
    else {
        Write-Host "Time reversal was $($time_span_raw.TotalMinutes) minutes"
        Write-Host "Time test: PASS"
         }
    Write-Host ""
    Write-Host ""

}