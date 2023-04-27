# Test-Wifi

This Script will Test your Wifi connection. measure things an put in into a csv file.

## Installation

You need Powershell v5.1 or higer 


## Usage

create a new dir and fork the project, or copy .ps1 and xml file into the folder.

open the xml file and edit your ping target, a server or fixed destination and enter the of your wifi NetAdapter [1]

[1] Run this: 
``` powershell
Get-NetAdapter -name WLAN | ft Name, Status, LinkTechnology
```
Example output:

``` powershell
Name Status LinkTechnology
---- ------ --------------
WLAN Up
```

XML
``` xml
<?xml version="1.0" encoding="utf-8" ?>
<config>
    <pingtarget>PING TARGET</pingtarget>
    <wifiname>NAME of NetAdapter</wifiname>
</config>
```

CSV

The CSV file is stored by default in the script folder 

``` CSV
"BSSID","ms","signalstrength","outgoing","incoming","IPv4","SSID","Destination","Status","Source","Name","timestamp"
"FF:FF:FF:FF:FF:FF","3"," : 60% ","","240","1.1.1.1","MyWifi","ServerX","connected","MyPC","WLAN","14.04.2023 10:59:26"
``` 
- BSSID = MAC of connected Router/AP
- ms = ms of the connection
- signalstrength = signalstrength to the Router/AP
- outgoing = bandwidth up in mbits/s
- incoming = bandwidht down in mbit/s
- IPv4 = Adresse you testing to
- SSID = Wifi SSID you are connected with
- Destination = Server you ping
- Status = shows if your Adapter is active
- Source = Your PC
- Name = Adapter Name
- Timestamp = time stamp

## Contributing

Pull requests are welcome. 

## License

Free to use, i'm happy to help