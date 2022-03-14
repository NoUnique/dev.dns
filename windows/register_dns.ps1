# ::SET DNS SERVER::
# read DNS server list from configs
$dir_root = Resolve-Path "$PSScriptRoot\.."
$dns_list = Get-Content "$dir_root\dns.conf"

Write-Output "DNS list:"
foreach ($ip in $dns_list) {
    Write-Output "${ip}"
}

# get interface indexes that already have IPv4 DNS server"
$interfaces = Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object {$_.ServerAddresses.Length -gt 0} | Select-Object -ExpandProperty "InterfaceIndex"

# set DNS server to the interfaces
foreach ($idx in $interfaces) {
    Write-Output "Set DNS server to interface#${idx}"
    Set-DnsClientServerAddress -InterfaceIndex ${idx} -ServerAddresses ${dns_list}
}

Write-Output "Done: ${dns_list}"


# ::SET PROXY EXCEPTIONS::
# read host list from configs
$dir_root = Resolve-Path "$PSScriptRoot\.."
$host_list = Get-Content "$dir_root\hosts"

#Write-Output "Host list:"
#foreach ($host_info in $host_list) {
#    Write-Output $host_info
#}

Write-Output "Proxy exception list:"
$exceptions = @()
foreach ($host_info in $host_list) {
    if ($host_info.StartsWith('#') -or [string]::IsNullOrWhiteSpace($host_info)) {
        continue  # pass comments
    }
    # split information into (ip, hostnames, ...)
    $host_info = $host_info -Replace '#.*$', '' -Split '\s+|\t+'
    $hostnames = $host_info[1..($host_info.length-1)]
    foreach ($info in $hostnames) {
        if ($info.Contains('.')) {
            $info = $info -Replace '^\.', ''  # remove leading period
            $exceptions += "*.$info"
            Write-Output "$info"
        }
    }
}


# get current proxy exception setup
$reg_key = "Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
$ignore_hosts = Get-ItemPropertyValue -Path $reg_key -Name ProxyOverride
# convert value into array
$ignore_hosts = $ignore_hosts.Split(";")

# add hosts to exception list
foreach ($hostname in $exceptions) {
    $ignore_hosts += $hostname
}

# remove duplicates
$ignore_hosts = $ignore_hosts | Select-Object -Unique
# join with semicolons
$ignore_hosts = $ignore_hosts -Join ";"

# set proxy exception list
Set-ItemProperty -Path $reg_key -Name ProxyOverride -Value $ignore_hosts
Write-Output "Following hosts are ignored by proxy:"
Write-Output "$ignore_hosts"
