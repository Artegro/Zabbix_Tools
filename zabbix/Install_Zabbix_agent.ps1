# Input parametr name for host to zabbix agent
param(
    [Parameter(Mandatory=$true)]
    [string]$NameAgent,
    [Parameter(Mandatory=$true)]
    [string]$Server,
    [array]$ipList
)

$uniqueIps = $ipList | Where-Object { $_ -and $_ -ne "" } | Select-Object -Unique

$agentconf = "c:\zabbix_agent7\conf\zabbix_agent.win.conf"
$PaternH = "Hostname="
$PaternS = "Server=192.168.0.1"

$tempFolder = Join-Path $env:TEMP "zabbix_download"
# Create temp folder
if (!(Test-Path $tempFolder)) {
    New-Item -ItemType Directory -Path $tempFolder -Force | Out-Null
}


$zipPath = Join-Path $tempFolder "zabbix_agent.zip"

# url zabbix zip file
$url = "https://github.com/Artegro/Zabbix_Tools/raw/main/zabbix/zabbix_agent.zip"
 
$targetFolder = "c:\"


 # Download & copy zabbix agent

Write-Host "download file..." -ForegroundColor Green
try {
    # Download
    Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing
    Write-Host "download access" -ForegroundColor Green
}
catch {
    Write-Host "download error: $_" -ForegroundColor Red
    exit 1
}

Write-Host "extract completed..." -ForegroundColor Green
try {
    
    Expand-Archive -Path $zipPath -DestinationPath $targetFolder -Force
    Write-Host "extract : $targetFolder" -ForegroundColor Green
}
catch {
    Write-Host "extract error: $_" -ForegroundColor Red
    exit 1
}


# Edit config Hostname & server
    try{
      (Get-Content $agentconf -ErrorAction Stop) -replace $PaternH, "Hostname=$NameAgent" | Set-Content $agentconf
    echo "IP:  Hostname: $NameAgent $agentconf " >> $tempFolder\log.txt
    }
    catch {
    echo "IP:  Hostname: $hostname Failed $($error[0])" >> $tempFolder\UPlog.txt
    }

    try{
      (Get-Content $agentconf -ErrorAction Stop) -replace $PaternS, "Server=$Server" | Set-Content $agentconf
    echo "IP:  Server: $Server $agentconf " >> $tempFolder\log.txt
    }
    catch {
    echo "IP:  Hostname: $hostname Failed $($error[0])" >> $tempFolder\UPlog.txt
    }

# Create services
        New-Service -Name "Zabbix Agent New" -BinaryPathName '"c:\zabbix_agent7\bin\zabbix_agentd.exe" --multiple-agents --config "C:\zabbix_agent7\conf\zabbix_agent.win.conf"' -DisplayName "Zabbix Agent New" -Description "Zabbix Agent to Server zabbix7" -StartupType "Automatic" 
        Start-Service  -Name 'Zabbix Agent*' 
        New-NetFirewallRule -DisplayName "Zabbix_Agent_Access"  -Profile Any -Program "%SystemDrive%\zabbix_agent7\bin\zabbix_agentd.exe" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 10050 -RemoteAddress $uniqueIps