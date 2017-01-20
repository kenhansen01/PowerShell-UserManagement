Function GetUsersFromAD {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ADServer = "corp.dir.ameren.com",
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$MemberOfGroup = "CN=Transmission,OU=Smart,OU=Managed,OU=Groups,DC=corp,DC=dir,DC=ameren,DC=com",
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$CSVPath = (Split-Path -Parent "$env:USERPROFILE\Documents\ExportADUsers\*.*"),
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$LogDate = (Get-Date -Format yyyyMMddhhmm),
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$CSVFile = "$CSVPath\AllADUsers_$LogDate.csv",
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$exportCSV = $true
    )

    Begin {
        if((Get-Module -ListAvailable -Name ActiveDirectory -ErrorAction SilentlyContinue) -eq $null) {
            Import-Module ActiveDirectory
        }

        function getUsers ($adServer, $memberOfGroup) {

            Write-Host "Getting all users in group:  $memberOfGroup, from server: $adServer" -ForegroundColor Blue

            $ADUsersInGroup = Get-ADUser -Server $adServer -Filter ({MemberOf -eq $memberOfGroup}) `
             -Properties GivenName,Surname,DisplayName,sAMAccountName,StreetAddress,City,State,PostalCode,
              Country,Title,Company,Description,Office,telephoneNumber,Mail,Manager,Enabled,LastLogonDate
            # | Where-Object {$_.info -NE 'Migrated'} #ensures that updated users are never exported.
            Write-Host "Got all users in group:  $memberOfGroup, from server: $adServer" -ForegroundColor Green
            return $ADUsersInGroup    
        }

        function saveUsersCSV ($csvFile, $adUsers) {
            
            Write-Host "Populating $csvFile with user information." -ForegroundColor Blue

            $adUsers | Select-Object `
                @{Label = "First Name";Expression = {$_.GivenName}},
                @{Label = "Last Name";Expression = {$_.Surname}},
                @{Label = "Display Name";Expression = {$_.DisplayName}},
                @{Label = "Logon Name";Expression = {$_.sAMAccountName}},
                @{Label = "Full address";Expression = {$_.StreetAddress}},
                @{Label = "City";Expression = {$_.City}},
                @{Label = "State";Expression = {$_.st}},
                @{Label = "Post Code";Expression = {$_.PostalCode}},
                @{Label = "Country/Region";Expression = {if (($_.Country -eq 'GB')  ) {'United Kingdom'} Else {''}}},
                @{Label = "Job Title";Expression = {$_.Title}},
                @{Label = "Company";Expression = {$_.Company}},
                @{Label = "Directorate";Expression = {$_.Description}},
                @{Label = "Department";Expression = {$_.Department}},
                @{Label = "Office";Expression = {$_.Office}},
                @{Label = "Phone";Expression = {$_.telephoneNumber}},
                @{Label = "Email";Expression = {$_.Mail}},
                @{Label = "Manager";Expression = {%{(Get-AdUser $_.Manager -server $ADServer -Properties DisplayName).DisplayName}}},
                @{Label = "Account Status";Expression = {if (($_.Enabled -eq 'TRUE')  ) {'Enabled'} Else {'Disabled'}}}, # the 'if statement# replaces $_.Enabled
                @{Label = "Last LogOn Date";Expression = {$_.lastlogondate}} | 

            #Export CSV report

            Export-Csv -Path $csvFile -NoTypeInformation

            Write-Host "CSV completed, it can be found at $csvFile" -ForegroundColor Green
        }
    }
    

    Process {
        if($PSCmdlet.ShouldProcess($CSVPath)) {
            $AllADUsers = getUsers $ADServer $MemberOfGroup
            if($exportCSV) {
                saveUsersCSV $CSVFile $AllADUsers
            }
            return $AllADUsers
        }
    }
}
