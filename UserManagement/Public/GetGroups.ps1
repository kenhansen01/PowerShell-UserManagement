Function GetSiteGroups {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Object]$SiteCollection,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$GroupName = $null
    )

    Begin {
        if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) {
            Add-PSSnapin "Microsoft.SharePoint.PowerShell"
        }

        function getAllSiteGroups ($siteColl) {    

            Write-Host "Getting site Collection Groups." -ForegroundColor Blue

            $allSiteGroups = $siteColl.RootWeb.Groups
        
            Write-Host "Got the site Collection Groups." -ForegroundColor Green
            return $allSiteGroups         
        }

        function getGroupByName ($siteColl, $groupName) {
        
            Write-Host "Getting group: $groupName from site: $siteColl" -ForegroundColor Blue

            $siteGroup = $siteColl.RootWeb.Groups.GetByName("$groupName")      

            Write-Host "Got group: $groupName from site: $siteColl" -ForegroundColor Green
            return $siteGroup
        }
    }

    Process {
        if($PSCmdlet.ShouldProcess($SiteCollection)) {
            if($GroupName -ne $null -or $GroupName -ne '') {
               $SiteGroups = getGroupByName $SiteCollection $GroupName 
            }
            else {
                $SiteGroups = getAllSiteGroups $SiteCollection
            }
            Write-Output $SiteGroups
        }
    }
}
