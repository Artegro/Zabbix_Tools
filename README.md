# Zabbix_Tools


# File Host_Create.ps1 Zabbix Agent Auto-Deployment Script for Windows Hosts

This PowerShell script automates the deployment and configuration of Zabbix agents on Windows hosts in an Active Directory environment. It automatically detects hosts based on naming conventions, installs the Zabbix agent, configures it, and registers them in Zabbix server with appropriate groups and templates.

## 📋 Prerequisites

- **Zabbix Server** with API access
- **Active Directory** environment
- **PowerShell** with administrative privileges
- **Network access** to target Windows hosts
- **DNS resolution** working for all target hosts
- **Admin shares** (C$) accessible on target hosts

## 🔧 Configuration

Before running the script, update the following variables:

```powershell
$Uri = "http://YourZabbixServer:Port/api_jsonrpc.php"         # Your Zabbix API URL
$Authorization = "Bearer YourAuthToken"                       # Your Zabbix API token
$pathfolder = "YourScriptFolderPath"                          # Path to script folder
$HostTS=(Get-ADComputer -Filter 'Name -like "*TS*"').Name     # You host name like
$HostHyper=(Get-ADComputer -Filter 'Name -like "hyper*"').Nam # You host name like
