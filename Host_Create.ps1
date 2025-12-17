$Uri = "http://You IP:Port/api_jsonrpc.php"
$Authorization = "Bearer AuthTokenZabbix"

$pathfolder="You carrent Path to scrint folder"
echo "" > $pathfolder\UPlog.txt
echo "" > $pathfolder\errlog.txt
#Path zabbix agent config Files
$st = "\zabbix_agent7\conf\zabbix_agent.win.conf"

#Get Groups
$testBody = @{
    jsonrpc="2.0"
    method="hostgroup.get"
    params=@{output="extend"}
    id=1
} | ConvertTo-Json

$Params = @{
    Uri = $Uri
    Headers = @{Authorization = $Authorization}
    Method = "Post"
    ContentType = "application/json"
    Body = $testBody
}

$resultg = Invoke-RestMethod @Params
foreach ($group in $resultg.result) {
    if ($group.Name -like "ULTIMA_APP*"){
        $group_app_id = $group.groupid
        Write-Host $group.groupid
        Write-Host $group.name
    }
    if ($group.Name -like "term*"){
        $group_term_id = $group.groupid
        Write-Host $group.groupid
        Write-Host $group.name
    }
    if ($group.Name -like "hyper"){
        $group_hyper_id = $group.groupid
        Write-Host $group.groupid
        Write-Host $group.name
    }
    if ($group.Name -like "windows*"){
        $group_windows_id = $group.groupid
        Write-Host $group.groupid
        Write-Host $group.name
    }
}



#Get Teamplate

$testBody = @{
    jsonrpc="2.0"
    method="template.get"
    params=@{
        output="extend"
        sortfield="name"
        }
    id=1
} | ConvertTo-Json

$Params = @{
    Uri = $Uri
    Headers = @{Authorization = $Authorization}
    Method = "Post"
    ContentType = "application/json"
    Body = $testBody
}


$resultt = Invoke-RestMethod @Params
foreach ($group in $resultt.result) {
    if ($group.Name -like "* ts *"){
        $templ_ts_id = $group.templateid
        Write-Host $group.templateid
        Write-Host $group.name
    }
    if ($group.Name -like "* hyper*" -and $group.Name -inotlike "vmware*"){
        $templ_hyper_id = $group.templateid
        Write-Host $group.templateid
        Write-Host $group.name
    }
    if ($group.Name -like "app_u*"){
        $templ_app_id = $group.templateid
        Write-Host $group.templateid
        Write-Host $group.name
    }
    if ($group.Name -like "windows_ag*"){
        $templ_windows_id = $group.templateid
        Write-Host $group.templateid
        Write-Host $group.name
    }
}


#Get Hosts
$HostTS=(Get-ADComputer -Filter 'Name -like "*kz*"').Name
$HostHyper=(Get-ADComputer -Filter 'Name -like "hyper*k"').Name
$HostS= $HostTS + $HostHyper


foreach ( $hostH in $HostS){
 #Reset group and template ID
   $templateid="31"
   $groupid="10636"
  try{
    (Resolve-DnsName $hostH -ErrorAction Stop)
    $pc=(Resolve-DnsName $hostH)
    $ip=$pc.ipaddress
    $hostname=$pc.name

    $agentconf = "\\$hostname\C`$\zabbix_agent7\conf\zabbix_agent.win.conf"
    $Patern = "Hostname="
   If (Test-Path "\\$hostname\C`$\zabbix_agent7"){
    echo "IP: $ip Hostname: $hostname Failed, The folder already exists" >> $pathfolder\UPlog.txt
   }else {
         #Copy Zabbix agent Files
        Copy-Item -Recurse C:\cmd\zab\zabbix_agent7 \\$hostname\C`$\zabbix_agent7
        Copy-Item -Recurse C:\cmd\zab\Zabbix \\$hostname\C`$\Zabbix
    
    
    echo ("IP: " + $ip + " Hostname: " + $hostname + " ### Добавление активного хоста в конфиг... ###")
    
    try{
      (Get-Content $agentconf -ErrorAction Stop) -replace $Patern, "Hostname=$hostname" | Set-Content $agentconf
    echo "IP: $ip Hostname: $hostname  $agentconf " >> $pathfolder\log.txt
    }
    catch {
    echo "IP: $ip Hostname: $hostname Failed $($error[0])" >> $pathfolder\UPlog.txt
    }
    $namesc = "Zabbix Agent "+$hostname
    echo $namesc

    Invoke-Command $hostname -ScriptBlock {New-Service -Name "Zabbix Agent New" -BinaryPathName '"c:\zabbix_agent7\bin\zabbix_agentd.exe" --multiple-agents --config "C:\zabbix_agent7\conf\zabbix_agent.win.conf"' -DisplayName "Zabbix Agent New" -Description "Zabbix Agent to Server zabbix7" -StartupType "Automatic" 
        Start-Service  -Name 'Zabbix Agent*' 
        New-NetFirewallRule -DisplayName "Zabbix_Agent_Access"  -Profile Any -Program "%SystemDrive%\zabbix_agent7\bin\zabbix_agentd.exe" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 10050
    }

    if ($pc.Name -like "hyper*" ){
        
        $groupid=$group_hyper_id
        $templateid=$templ_hyper_id
    
    } elseif ($pc.Name -like "Virt-termKZ*"){
        $groupid=$group_term_id
        $templateid=$templ_ts_id
    
    } elseif ($pc.Name -like "Virt-APPZ*"){
        $groupid=$group_app_id
        $templateid=$templ_app_id
    
    } else {
        $groupid=$group_windows_id
        $templateid=$templ_windows_id
    }
    Write-Host $groupid
    Write-Host $templateid
   # Read-Host
    $testBody = @{
    "jsonrpc"="2.0"
    "method"="host.create"
     "params"=@{
         "host"="$hostname"
     
        "interfaces"= @{
                "type"="1"
                "main"="1"
                "useip"="1"
                "ip"="$ip"
                "dns"=""
                "port"="10050"
            }
    
        "groups"= @{
                "groupid"="$groupid"
            }
        
        "templates"= @{
                "templateid"="$templateid"
            }
        "inventory_mode"="0"

 
    }
   "id"="1"
   }  #$testBody


    $Params = @{
        Uri = $Uri
        Headers = @{Authorization = $Authorization}
        Method = "Post"
        ContentType = "application/json"
        Body = (ConvertTo-Json $testBody)
    }
    Invoke-RestMethod @Params
   # Read-Host
  } 
  echo "IP: $ip Hostname: $hostname  seccess" >> $pathfolder\log.txt
    }
    catch {
    echo "IP: $ip Hostname: $hostname Failed $($error[0])" >> $pathfolder\UPlog.txt
    }    
}

