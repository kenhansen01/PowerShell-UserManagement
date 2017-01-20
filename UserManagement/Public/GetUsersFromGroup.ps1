Function GetUsersFromGroup {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Object]$Group,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$UserEmail = $null
    )

    Begin {
        if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) {
            Add-PSSnapin "Microsoft.SharePoint.PowerShell"
        }

        function getAllGroupUsers ($group) {    

            Write-Host "Getting $group users." -ForegroundColor Blue

            $allGroupUsers = $group.Users
        
            Write-Host "Got $group users." -ForegroundColor Green
            return $allGroupUsers         
        }

        function getUserInGroup($group, $userEmail) {
        
            Write-Host "Getting $userEmail from $group" -ForegroundColor Blue

            $groupUser = $group.Users.GetByEmail($userEmail)    

            Write-Host "Got $userEmail from $group" -ForegroundColor Green
            return $groupUser
        }
    }

    Process {
        if($PSCmdlet.ShouldProcess($Group)) {
            if($UserEmail -ne $null -and $UserEmail -ne '') {
               $GroupUsers = getUserInGroup $Group $UserEmail 
            }
            else {
                $GroupUsers = getAllGroupUsers $Group
            }
            Write-Output $GroupUsers
        }
    }
}
