#   To install agent services use command

```
powershell -ExecutionPolicy Bypass -Command "$scriptPath=\"$env:TEMP\Install_Zabbix_agent.ps1\"; Invoke-WebRequest -Uri 'https://github.com/Artegro/Zabbix_Tools/raw/main/zabbix/Install_Zabbix_agent.ps1' -OutFile $scriptPath; & $scriptPath -NameAgent 'Hostname' -Server 'IP Zabbiz server' -ipList @('Access ip1', 'Access ip2'..., 'Access ipN')"
```
