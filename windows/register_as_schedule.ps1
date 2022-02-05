$MainFunction={
    $dir_root = Resolve-Path "$PSScriptRoot\.."
    $path_script = Resolve-Path "${dir_root}\windows\register_dns.ps1"
    $delay = 15
    $task_name = "SetDNS"

    # Create Scheduled Task
    Invoke-PrepareScheduledTask -Name $task_name -Path $path_script -Delay $delay
    Start-ScheduledTask $task_name
}

# The following code has been written by referring to the following pages:
# https://docs.microsoft.com/ko-kr/powershell/scripting/learn/ps101/09-functions?view=powershell-7.2
# https://stackoverflow.com/questions/36846688/powershell-run-job-at-startup-with-admin-rights-using-scheduledjob
# https://gist.github.com/primeinc/486795211d9c64e56d262d27e4f282db
function Invoke-PrepareScheduledTask
{
    param (
        [Parameter(Mandatory=$true)][Alias("Name")][string]$taskName,
        [Parameter(Mandatory=$true)][Alias("Path")][string]$script,
        [Parameter(Mandatory=$true)][Alias("Delay")][int]$delaySeconds
    )
    # convert integer to datatime stamp
    $delayTimespan = [timespan]::fromseconds($delaySeconds)
    $delayDatetime = "{0:hh:mm:ss}" -f ([datetime]$delayTimespan.Ticks)

    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($null -ne $task)
    {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false 
    }

    $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-ExecutionPolicy Unrestricted -File ""$script"""
    $trigger = New-ScheduledTaskTrigger -AtLogOn -RandomDelay $delayDatetime
    $settings = New-ScheduledTaskSettingsSet -Compatibility Win8
    $principal = New-ScheduledTaskPrincipal -UserId SYSTEM -LogonType ServiceAccount -RunLevel Highest

    $definition = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings -Description "Run $($taskName) at startup"

    Register-ScheduledTask -TaskName $taskName -InputObject $definition

    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($null -ne $task)
    {
        Write-Output "Created scheduled task: '$($task.ToString())'."
    }
    else
    {
        Write-Output "Created scheduled task: FAILED."
    }
}


& $MainFunction
