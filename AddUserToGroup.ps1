Function AddUserToGroup {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Object]$Group,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$UserId
    )

    Begin {
        if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) {
            Add-PSSnapin "Microsoft.SharePoint.PowerShell"
        }

        function addUser ($group, $userid) {    

            Write-Host "Adding $user to $group." -ForegroundColor Blue

            try { 
                $spuser = $group.ParentWeb.EnsureUser("ameren\$userid")
            }
            catch {
                $spuser = New-SPUser -UserAlias "ameren\$userid" -Web $group.ParentWeb
            }
            
            $group.AddUser($spUser)
        
            Write-Host "Added $user to $group." -ForegroundColor Green
            return $spUser        
        }

    }

    Process {
        if($PSCmdlet.ShouldProcess($Group)) {
            $GroupUser = addUser $Group $UserId
            Write-Output $GroupUser
        }
    }
}
