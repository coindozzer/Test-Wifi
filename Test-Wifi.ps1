<#
    Powershell - Description of Script here

    Return codes:
#>

#region LocalTesting
<# 
#>
#endregion

#region ActionPreference
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
$VerbosePreference     = [System.Management.Automation.ActionPreference]::SilentlyContinue
#endregion
  
#region Script Variables
$ScriptPath            = if ($MyInvocation.MyCommand.Path) { $MyInvocation.MyCommand.Path } elseif ($psIse) { $psISE.CurrentFile.FullPath } elseif (Get-Location) { ((get-Location).path + '\*' | Get-ChildItem -Include *.ps1 | Select-Object FullName).FullName } else { Write-Error 'Could not get script path!' }
$ScriptFolder          = Split-Path -Path $ScriptPath
$ScriptTemp            = Join-Path  -Path $ScriptFolder -ChildPath 'temp'
$ScriptLogFolder       = Join-Path  -Path $ScriptFolder -ChildPath 'log'
$ScriptXml             = Join-Path  -Path $ScriptFolder -ChildPath ('{0}.xml' -f [System.IO.Path]::GetFileNameWithoutExtension($ScriptPath))
$ScriptStartDate       = Get-Date
$ScriptTranscript      = $true
#endregion
  
#region Start Transcript
if ($ScriptTranscript)
{
  $ScriptLogFile = Join-Path $ScriptLogFolder ('{0}_{1:yyyy-MM-dd_HHmmss.fff}.txt' -f [System.IO.Path]::GetFileNameWithoutExtension($ScriptPath), $ScriptStartDate)
    
  if (-not (Test-Path $ScriptLogFolder))
  {
    $null = mkdir $ScriptLogFolder
  }
  
  Start-Transcript -LiteralPath $ScriptLogFile  
}
#endregion

#Trace-Output for Transcript
function Trace-Output($txt)
{
  <# 

      This is only for Display in SARA

  #>
  
  Write-Host (Get-Date) : $txt
  return

}

## load XML Settings ##
$xml = $null
$xml = New-Object xml
$xml.Load($ScriptXml)

######## Wifi Test ######
$pingTarget = $xml.config.pingtarget
$wlanName = $xml.config.wifiname
$i = 0
$pingtest = @()
$aufzeichnung = @()

if($PSVersionTable.PSVersion.Major -gt 5)
{
    function get-ping {

        param (
            $targetname
        )
        $ping = Test-Connection $targetname -Count 1 -IPv4
        $output = New-Object psobject -Property @{
            Source = $ping.Source
            Destination = $targetname
            IPv4 = $ping.Address
            ms = $ping.Latency
            timestamp = Get-Date -Format "dd/MM/yyyy HH:MM:ss"
        }
        return $output
    }
}
else {
    function get-ping {

        param (
            $targetname
        )
        $ping = Test-Connection $targetname -Count 1
        $output = New-Object psobject -Property @{
            Source = $ping.Path.Server
            Destination = $ping.Address
            IPv4 = $ping.IPV4Address
            ms = $ping.ResponseTime
            timestamp = Get-Date -Format "dd/MM/yyyy HH:MM:ss"
        }
        return $output
    }
}

function get-wlaninfo {

    param (
        $wlan_name,
        $ping_target
    )
    $pingtest = $null
    $output = @()
    $wlan_infos = netsh $wlan_name show interfaces
    $pingtest = get-ping -targetname $ping_target
    if($wlan_infos[7].Substring(29) -eq 'getrennt')
    {
        $output += New-Object psobject -Property @{
        Name            = $wlan_infos[3].Substring(29) #WLAN NAME
        Status          = $wlan_infos[7].Substring(29) #WLAN Status
        SSID            = 'not possible'
        BSSID           = 'not possible'
        incoming        = 'not possible'
        outgoing        = 'not possible'
        signalstrength  = 'not possible'
        timestamp       = Get-Date
        Source          = 'not possible'
        Destination     = 'not possible'
        IPv4            = 'not possible'
        ms              = 'not possible'
        }
    }
    else
    {
        $output += New-Object -TypeName psobject -Property @{
        Name            = $wlan_infos[3].Substring(29) #WLAN NAME
        Status          = $wlan_infos[7].Substring(29) #WLAN Status
        SSID            = $wlan_infos[8].Substring(29) #WLAN SSID MAC
        BSSID           = $wlan_infos[9].Substring(29) #WLAN BSSID MAC
        incoming        = $wlan_infos[16].Substring(29) #WLAN Empfangsrate
        outgoing        = $wlan_infos[17].Substring(32) #WLAN Senderate
        signalstrength  = $wlan_infos[18].Substring(26) #WLAN SignalstÃ¤rke
        timestamp       = Get-Date
        Source          = $pingtest.Source
        Destination     = $pingtest.Destination
        IPv4            = $pingtest.IPv4
        ms              = $pingtest.ms 
        }
    }
    return $output
}

while ($i -ne (10))
{
    $aufzeichnung += get-wlaninfo -wlan_name $wlanName -ping_target $pingtarget
    <# write-host | #> get-wlaninfo -wlan_name $wlanName -ping_target $pingtarget
    Start-Sleep -Seconds 1
    $i++

}

$aufzeichnung | Export-Csv -Path ("{0}\{1}_wlan_traceing.csv" -f $ScriptPath, $env:COMPUTERNAME)
 

#region Stop Transcript
if ($ScriptTranscript)
{
  Stop-Transcript
}
#endregion
Exit $exitcode

#miscellaneous 
# Get-Command -Module NetAdapter
# Get-Command -Module NetTCPIP
# Get-NetIPInterface -InterfaceAlias WLAN | Format-List
# Get-NetAdapterBinding
# Get-NetAdapter -name WLAN | ft Name, Status, LinkTechnology