Function GetSPSites {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$rootUrl = $null,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$serverRelativeSiteUrl = $null,
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$allSubs = $true
    )

    Begin {
        if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) {
            Add-PSSnapin "Microsoft.SharePoint.PowerShell"
        }

        function getSiteCollections ($siteCollectionUrl) {    

            Write-Host "Getting site Collection(s)." -ForegroundColor Blue

            if($siteCollectionUrl -eq $null -or $siteCollectionUrl -eq '') {
                $siteCollections = Get-SPSite
            }
            else {
                $siteCollections = Get-SPSite $siteCollectionUrl
            }
        
            Write-Host "Got the site Collection(s)." -ForegroundColor Green
            return $siteCollections         
        }

        function getSubWebs ($parentWeb) {
        
            Write-Host "Getting sub sites of $parentWeb" -ForegroundColor Blue

            $SubWebsToUse = New-Object System.Collections.Generic.List[System.Object]

            foreach($web in $parentWeb.Webs) {
                $SubWebsToUse.Add((New-Object -TypeName PSObject -Prop (@{'Web' = $web; 'SubWebs' = getSubWebs($web) })))
            }       

            Write-Host "Got sub sites of $parentWeb" -ForegroundColor Green
            return $SubWebsToUse
        }
    }

    Process {
        if($PSCmdlet.ShouldProcess($CSVPath)) {
            $SitesToUse = New-Object System.Collections.Generic.List[System.Object]
            foreach ($site in getSiteCollections($rootUrl + $serverRelativeSiteUrl)) {
                if($allSubs) {
                    $SitesToUse.Add((New-Object -TypeName PSObject -Prop (@{'RootWeb' = $site.RootWeb; 'SubWebs' = getSubWebs($site.RootWeb) })))
                }
                else {
                    $SitesToUse.Add((New-Object -TypeName PSObject -Prop (@{'RootWeb' = $site.RootWeb; 'SubWebs' = $null })))
                }
            }
            Write-Output $SitesToUse
        }
    }
}
