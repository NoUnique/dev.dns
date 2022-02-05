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
